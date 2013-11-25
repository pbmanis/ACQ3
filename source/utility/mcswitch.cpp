/*	MCSWITCH - detect MC700A mode change

	[FLAG, OLD, NEW] = MCSWITCH detects a mode change from the
	MC700A telegraph server and sets FLAG to TRUE if the change
	occurred before a timeout period.  The OLD and NEW modes are
	also returned.
  
	[ ... ] = MCSWITCH(COM, BUS, CHAN, TIMEOUT) allows the user
	to specify the COM port (default is 1), the bus ID (default
	is 0), the amplifier channel (default is 1), and the timeout
	duration in seconds (default is 30 sec).
	
	In order to utilize the Windows Messaging service, this code
	creates an invisible window (ShowWindow & UpdateWindow are
	not called) that is destroyed as soon as the telegraph data
	is obtained.
	  
	7/11/03 SCM */

// inclusions
#include <windows.h>		// for Windows API
#include "mcswitch.h"		// for MC700A telegraphs
#include "mex.h"			// for MATLAB mex file

// prototypes
long WINAPI WindowProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam);
void connect_telegraph(HWND hWnd);

// Windows Messaging server variables
static UINT s_uMCTGOpenMessage      = 0;
static UINT	s_uMCTGCloseMessage     = 0;
static UINT	s_uMCTGRequestMessage   = 0;
static UINT	s_uMCTGReconnectMessage = 0;
static UINT	s_uMCTGBroadcastMessage = 0;
static UINT	s_uMCTGIdMessage        = 0;
static UINT s_uMCTGOldAmpMode		= 0;	// storage for old amplifier mode
static UINT s_uMCTGNewAmpMode		= 0;	// storage for new amplifier mode

// timer variables
static UINT s_cuConnectionTimerEventID  = 13377;	// arbitrary connection timer ID
static UINT s_cuConnectionTimerInterval =  1000;	// wait 1000 ms for connection
static UINT s_cuModeSwitchTimerEventID  = 24488;	// arbitrary mode switch timer ID
static UINT s_cuModeSwitchTimerInterval = 30000;	// wait 30000 ms for mode switch (default)

// MC700A telegraph server variables
static BOOL	m_bIsConnected = FALSE;		// TRUE if connected to telegraph server
static BOOL	m_bIsConnecting = FALSE;	// TRUE if attempting to connect to telegraph server
static BOOL m_bIsError = FALSE;			// TRUE if error occurred, FLAG = FALSE on error
static BOOL m_bIsOldAmpMode = FALSE;	// TRUE if starting mode obtained
static BOOL m_bIsNewAmpMode = FALSE;	// TRUE if mode change detected
static MC_TELEGRAPH_DATA m_mctdCurrentState;	// structure containing MC700A telegraph data

// entry point for MEX call
// modified from WinMain call
// added fake WinMain args (it works!)
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

	// fake WinMain args
	HINSTANCE	hInstance = (HINSTANCE) 0x00400000;	// typical value with WinMain calls
	HINSTANCE	hPrevInstance = (HINSTANCE) NULL;	// no longer used with Win32
	LPSTR		lpCmdLine = "";	// no command line args
	int			nCmdShow = 1;	// typical value with WinMain calls
	
	// window variables
	static char	szAppName[] = "MCSwitchWin";	// window class name
	HWND		hWnd;			// window handle
	MSG			msg;			// message structure
	WNDCLASS	WindowClass;	// window attributes

	// output assignment
	int			i;				// output assignment loop variable

	// initialize the telegraph state
	m_mctdCurrentState.uVersion           = MCTG_API_VERSION;
	m_mctdCurrentState.uStructSize        = sizeof(MC_TELEGRAPH_DATA);
	m_mctdCurrentState.uComPortID         = 1;
	m_mctdCurrentState.uAxoBusID          = 0;
	m_mctdCurrentState.uChannelID         = 1;
	m_mctdCurrentState.uOperatingMode     = MCTG_MODE_VCLAMP;
	m_mctdCurrentState.uScaledOutSignal   = MCTG_OUT_MUX_COMMAND;
	m_mctdCurrentState.dAlpha             = 0.0;
	m_mctdCurrentState.dScaleFactor       = 0.0;
	m_mctdCurrentState.uScaleFactorUnits  = MCTG_UNITS_VOLTS_PER_VOLT;
	m_mctdCurrentState.dLPFCutoff         = 0.0;
	m_mctdCurrentState.dMembraneCap       = 0.0;
	m_mctdCurrentState.dExtCmdSens        = 0.0;
	
	// obtain COM port, bus and channel IDs and timeout period
	// design SWITCH to fall through and pick up multiple args if needed
	switch (nrhs) {
	case 4:
		if (mxIsNumeric(prhs[3]) && (mxGetNumberOfElements(prhs[3]) == 1)) {
			s_cuModeSwitchTimerInterval = (UINT) (1000.0 * mxGetScalar(prhs[3]));
		}
	case 3:
		if (mxIsNumeric(prhs[2]) && (mxGetNumberOfElements(prhs[2]) == 1)) {
			m_mctdCurrentState.uChannelID = (UINT) mxGetScalar(prhs[2]);
		}
	case 2:
		if (mxIsNumeric(prhs[1]) && (mxGetNumberOfElements(prhs[1]) == 1)) {
			m_mctdCurrentState.uAxoBusID = (UINT) mxGetScalar(prhs[1]);
		}
	case 1:
		if (mxIsNumeric(prhs[0]) && (mxGetNumberOfElements(prhs[0]) == 1)) {
			m_mctdCurrentState.uComPortID = (UINT) mxGetScalar(prhs[0]);
		}
	case 0:
		m_bIsError = FALSE;
		m_bIsOldAmpMode = FALSE;
		m_bIsNewAmpMode = FALSE;
		break;
	default:
        mexWarnMsgTxt("type 'help mcswitch' for syntax");
		m_bIsError = TRUE;
		m_bIsOldAmpMode = FALSE;
		m_bIsNewAmpMode = FALSE;
		break;
	}
	
	// register messages with Windows Messaging server
	if (m_bIsError) {	// error already, do nothing
	}
	else if ((s_uMCTGOpenMessage = RegisterWindowMessage(MCTG_OPEN_MESSAGE_STR)) == 0) {
		mexWarnMsgTxt("failed to register MCTG_OPEN_MESSAGE_STR");
		m_bIsError = TRUE;
	}
	else if ((s_uMCTGCloseMessage = RegisterWindowMessage(MCTG_CLOSE_MESSAGE_STR)) == 0) {
		mexWarnMsgTxt("failed to register MCTG_CLOSE_MESSAGE_STR");
		m_bIsError = TRUE;
	}
	else if ((s_uMCTGRequestMessage = RegisterWindowMessage(MCTG_REQUEST_MESSAGE_STR)) == 0) {
		mexWarnMsgTxt("failed to register MCTG_REQUEST_MESSAGE_STR");
		m_bIsError = TRUE;
	}
	else if ((s_uMCTGReconnectMessage = RegisterWindowMessage(MCTG_RECONNECT_MESSAGE_STR)) == 0) {
		mexWarnMsgTxt("failed to register MCTG_RECONNECT_MESSAGE_STR");
		m_bIsError = TRUE;
	}
	else if ((s_uMCTGBroadcastMessage = RegisterWindowMessage(MCTG_BROADCAST_MESSAGE_STR)) == 0) {
		mexWarnMsgTxt("failed to register MCTG_BROADCAST_MESSAGE_STR");
		m_bIsError = TRUE;
	}
	else if ((s_uMCTGIdMessage = RegisterWindowMessage(MCTG_ID_MESSAGE_STR)) == 0) {
		mexWarnMsgTxt("failed to register MCTG_ID_MESSAGE_STR");
		m_bIsError = TRUE;
	}
	
	// create a window for messaging server
	// need to make this object invisible!!
	// define window attributes
	if (!m_bIsError) {
		WindowClass.cbClsExtra =	0;				// no extra bytes after window class
		WindowClass.cbWndExtra =	0;				// structure or window instance??
		WindowClass.hbrBackground =	(HBRUSH__ *) GetStockObject(LTGRAY_BRUSH);	// gray background
		WindowClass.hCursor =		LoadCursor(0, IDC_ARROW);		// default cursor
		WindowClass.hIcon =			LoadIcon(0, IDI_APPLICATION);	// default icon
		WindowClass.hInstance =		hInstance;		// app instance handle, passed via WinMain;
		WindowClass.lpfnWndProc =	WindowProc;		// PROCEDURE FOR MESSAGE HANDLING
		WindowClass.lpszMenuName =	0;				// no menu
		WindowClass.lpszClassName =	szAppName;		// window class name
		WindowClass.style =			CS_HREDRAW | CS_VREDRAW;		// allow for resizing
		
		// register our window class
		RegisterClass(&WindowClass);
		
		// create window
		hWnd = CreateWindow(
			szAppName,				// window class name
			"MC 700A Telegraph",	// window title string
			WS_OVERLAPPEDWINDOW,	// overlapped window style
			CW_USEDEFAULT,			// default horizontal position (left)
			CW_USEDEFAULT,			// default vertical position (top)
			CW_USEDEFAULT,			// default horizontal size
			CW_USEDEFAULT,			// default vertical size
			0,						// no parent window
			0,						// no menu
			hInstance,				// program instance handle
			0);						// no window creation data
		
		//ShowWindow(hWnd, nCmdShow);	// display window (DO I HAVE TO?)
		//UpdateWindow(hWnd);			// cause client area to be drawn (DO I HAVE TO?)
		connect_telegraph(hWnd);		// connect to telegraph server
		
		// message loop
		// exits when WM_QUIT is posted
		while (GetMessage(&msg, 0, 0, 0) == TRUE) {
			TranslateMessage(&msg);	// translate message
			DispatchMessage(&msg);	// dispatch message
		}
	}

	// outputs are FLAG, OLD mode & NEW mode
	// provide excess outputs if needed
	for (i = 0; i < nlhs; i++) {
		switch (i) {
		case 0:
			plhs[i] = mxCreateDoubleScalar((double) !m_bIsError &&
				(m_bIsOldAmpMode && m_bIsNewAmpMode));
			break;
		case 1:
			plhs[i] = mxCreateString(MCTG_MODE_NAMES[s_uMCTGOldAmpMode]);
			break;
		case 2:
			plhs[i] = mxCreateString(MCTG_MODE_NAMES[s_uMCTGNewAmpMode]);
			break;
		default:
			plhs[i] = mxCreateDoubleMatrix(0, 0, mxREAL);
			break;
		}
    }
}

// message handling routine
long WINAPI WindowProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam) {
	
	long				ret_val = 0L;		// return value
	COPYDATASTRUCT*		pcpds;				// data from WM_COPYDATA event
	LPARAM				lparamSignalIDs;	// signal ID from telegraph server
	MC_TELEGRAPH_DATA*	pmctdReceived;		// data from telegraph server
	
	// pack signals into LPARAM variable
	lparamSignalIDs = MCTG_PackSignalIDs(m_mctdCurrentState.uComPortID,
		m_mctdCurrentState.uAxoBusID, m_mctdCurrentState.uChannelID);
	
	switch (message) {	// act on message
		
	case WM_PAINT:		// do nothing on redraw
		break;
		
	case WM_DESTROY:	// disconnect & post WM_QUIT on destroy
		connect_telegraph(hWnd);
		PostQuitMessage(0);
		break;
		
	case WM_TIMER:		// timer has expired

		// telegraph connection timed out
		if (wParam == s_cuConnectionTimerEventID) {
			m_bIsConnecting = FALSE;
			KillTimer(hWnd, s_cuConnectionTimerEventID);
			if (!m_bIsConnected) {
				mexWarnMsgTxt("telegraph connection timed out");
				m_bIsError = TRUE;
				DestroyWindow(hWnd);
			}
		}

		// mode switch timed out
		if (wParam == s_cuModeSwitchTimerEventID) {
			KillTimer(hWnd, s_cuModeSwitchTimerEventID);
			DestroyWindow(hWnd);
		}
		break;
		
	case WM_COPYDATA:	// telegraph data available
		// check if WM_COPYDATA message contains MC_TELEGRAPH_DATA
		// obtain pointer to data
		pcpds = (COPYDATASTRUCT*) lParam;
		if ((pcpds->cbData == sizeof(MC_TELEGRAPH_DATA)) &&
			(pcpds->dwData == (DWORD) s_uMCTGRequestMessage)) {
			pmctdReceived = (MC_TELEGRAPH_DATA*) pcpds->lpData;
			
			// check if data from our MultiClamp device / channel
			if (MCTG_MatchSignalIDs(pmctdReceived->uComPortID,
				pmctdReceived->uAxoBusID, pmctdReceived->uChannelID, lparamSignalIDs)) {
				
				// update telegraph structure
				m_mctdCurrentState.uOperatingMode		= pmctdReceived->uOperatingMode;
				m_mctdCurrentState.uScaledOutSignal		= pmctdReceived->uScaledOutSignal;
				m_mctdCurrentState.dAlpha				= pmctdReceived->dAlpha;
				m_mctdCurrentState.dScaleFactor			= pmctdReceived->dScaleFactor;
				m_mctdCurrentState.uScaleFactorUnits	= pmctdReceived->uScaleFactorUnits;
				m_mctdCurrentState.dLPFCutoff			= pmctdReceived->dLPFCutoff;
				m_mctdCurrentState.dMembraneCap			= pmctdReceived->dMembraneCap;
				m_mctdCurrentState.dExtCmdSens			= pmctdReceived->dExtCmdSens;
				m_mctdCurrentState.uRawOutSignal		= pmctdReceived->uRawOutSignal;
				m_mctdCurrentState.dRawScaleFactor		= pmctdReceived->dRawScaleFactor;
				m_mctdCurrentState.uRawScaleFactorUnits	= pmctdReceived->uRawScaleFactorUnits;
				
				// check whether attempt to connect has succeeded before the timeout
				// m_bIsConnected must be set before updating display
				if (m_bIsConnecting) {
					m_bIsConnected  = TRUE;
					m_bIsConnecting = FALSE;
					KillTimer(hWnd, s_cuConnectionTimerEventID);
				}

				// obtain starting mode if needed
				// start timer for mode switch
				if (!m_bIsOldAmpMode) {
					s_uMCTGOldAmpMode = m_mctdCurrentState.uOperatingMode;
					m_bIsOldAmpMode = TRUE;
					if (SetTimer(hWnd, s_cuModeSwitchTimerEventID, 
						s_cuModeSwitchTimerInterval, (TIMERPROC) NULL) == 0) {
						mexWarnMsgTxt("failed to set mode switch timer");
						m_bIsError = TRUE;
						DestroyWindow(hWnd);
					}
				}

				// obtain mode if changed
				// we have the info we need
				// can disconnect & kill window
				else if (!m_bIsNewAmpMode) {
					if (m_mctdCurrentState.uOperatingMode != s_uMCTGOldAmpMode) {
						s_uMCTGNewAmpMode = m_mctdCurrentState.uOperatingMode;
						m_bIsNewAmpMode = TRUE;
						DestroyWindow(hWnd);
					}
				}

				// otherwise kill process
				// shouldn't ever get here!
				else {
					DestroyWindow(hWnd);
				}
			}
		}
		break;
		
	default:			// default message processing

		// check for telegraph reconnect request
		// reestablish connection if command is from our server
		if (message == s_uMCTGReconnectMessage) {
			if (m_bIsConnected && MCTG_MatchSignalIDs(m_mctdCurrentState.uComPortID,
				m_mctdCurrentState.uAxoBusID, m_mctdCurrentState.uChannelID, lParam)) {
				m_bIsConnected = FALSE;
				connect_telegraph(hWnd);
			}
		}

		// check for broadcast ID request
		// nothing to do here
		else if (message == s_uMCTGIdMessage) {
		}

		// otherwise utilize default windows message processing
		else {
			ret_val = DefWindowProc(hWnd, message, wParam, lParam);
		}
		break;
	}
	return(ret_val);
}

// connect to telegraph server
void connect_telegraph(HWND hWnd) {
	
	LPARAM lparamSignalIDs;		// signal ID from telegraph server
	
	// pack signals into LPARAM variable
	lparamSignalIDs = MCTG_PackSignalIDs(m_mctdCurrentState.uComPortID,
		m_mctdCurrentState.uAxoBusID, m_mctdCurrentState.uChannelID);
	
	// we are already connected
	// this is a request to disconnect
	if (m_bIsConnected) {
		if (!PostMessage(HWND_BROADCAST, s_uMCTGCloseMessage, (WPARAM) hWnd, lparamSignalIDs)) {
			mexWarnMsgTxt("failed to close connection");
			m_bIsError = TRUE;
			DestroyWindow(hWnd);
		}
		m_bIsConnected = FALSE;
	}

	// we are not connected
	// this is a request to connect
	// set timer to prevent long wait for reply
	// WINDOWPROC will handle the rest
	else {
		if (PostMessage(HWND_BROADCAST, s_uMCTGOpenMessage, (WPARAM) hWnd, lparamSignalIDs)) {
			m_bIsConnecting = TRUE;
			if (SetTimer(hWnd, s_cuConnectionTimerEventID, 
				s_cuConnectionTimerInterval, (TIMERPROC) NULL) == 0) {
				mexWarnMsgTxt("failed to set connection timer");
				m_bIsError = TRUE;
				DestroyWindow(hWnd);
			}
		}
		else {
			m_bIsConnecting = FALSE;
			mexWarnMsgTxt("failed to open connection");
			m_bIsError = TRUE;
			DestroyWindow(hWnd);
		}
	}
}

/*	MCTELEGRAPH - read MC700A telegraph info

	MCSTRUCT = MCTELEGRAPH obtains the current state of the
	Multiclamp 700A telegraph server and returns these values
	to MCSTRUCT.
  
	MCSTRUCT = MCTELEGRAPH(COM, BUS, CHAN) allows the user to
	specify the COM port (default is 1), the bus ID (default
	is 0), and the amplifier channel (default is 1).
	
	In order to utilize the Windows Messaging service, this code
	creates an invisible window (ShowWindow & UpdateWindow are
	not called) that is destroyed as soon as the telegraph data
	is obtained.
	  
	7/1/03 SCM */

// inclusions
#include <windows.h>		// for Windows API
#include "mctelegraph.h"	// for MC700A telegraphs
#include "mex.h"			// for MATLAB mex file

// definitions
#define FIELD_COUNT	16		// number of fields in output structure
#define FIELD_SIZE	12		// max length for field names in output structure

// prototypes
long WINAPI WindowProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam);
void connect_telegraph(HWND hWnd);
char **create_2D_array(int nstring, int nchar);
void destroy_2D_array(char **char_array, int nstring);

// Windows Messaging server variables
static UINT s_uMCTGOpenMessage      = 0;
static UINT	s_uMCTGCloseMessage     = 0;
static UINT	s_uMCTGRequestMessage   = 0;
static UINT	s_uMCTGReconnectMessage = 0;
static UINT	s_uMCTGBroadcastMessage = 0;
static UINT	s_uMCTGIdMessage        = 0;

// timer variables
static const UINT s_cuConnectionTimerEventID  = 13377; // arbitrary connection timer ID
static const UINT s_cuConnectionTimerInterval = 1000;  // wait 1000 ms for connection

// MC700A telegraph server variables
static BOOL	m_bIsConnected = FALSE;		// TRUE if connected to telegraph server
static BOOL	m_bIsConnecting = FALSE;	// TRUE if attempting to connect to telegraph server
static BOOL m_bIsUpdated = FALSE;		// TRUE if telegraph values have been updated once
static BOOL m_bIsError = FALSE;			// TRUE if error occurred, returns [] on error
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
	static char	szAppName[] = "MCTeleWin";	// window class name
	HWND		hWnd;			// window handle
	MSG			msg;			// message structure
	WNDCLASS	WindowClass;	// window attributes

	// output structure variables
	char		**field_list;	// structure field names
	double		output_gain;	// product of headstage & amplifier gain
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
	
	// obtain COM port, bus and channel IDs
	// design SWITCH to fall through and pick up multiple args if needed
	switch (nrhs) {
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
		m_bIsUpdated = FALSE;
		break;
	default:
        mexWarnMsgTxt("type 'help mctelegraph' for syntax");
		m_bIsError = TRUE;
		m_bIsUpdated = FALSE;
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

	// output is MATLAB structure if successful
	// assign field names
	// create output structure
	if (m_bIsUpdated && (!m_bIsError)) {
		field_list = create_2D_array(FIELD_COUNT, FIELD_SIZE);
		strcpy(field_list[0], "hardware");
		strcpy(field_list[1], "channel");
		strcpy(field_list[2], "mode");
		strcpy(field_list[3], "output_gain");
		strcpy(field_list[4], "scaled_name");
		strcpy(field_list[5], "scaled_gain");
		strcpy(field_list[6], "scaled_unit");
		strcpy(field_list[7], "raw_name");
		strcpy(field_list[8], "raw_gain");
		strcpy(field_list[9], "raw_unit");
		strcpy(field_list[10], "lpf");
		strcpy(field_list[11], "lpf_unit");
		strcpy(field_list[12], "cm");
		strcpy(field_list[13], "cm_unit");
		strcpy(field_list[14], "extcmd");
		strcpy(field_list[15], "extcmd_unit");
		plhs[0] = mxCreateStructMatrix(1, 1, FIELD_COUNT, (const char **) field_list);

		// amplifier name
		if (m_mctdCurrentState.uHardwareType < MCTG_HW_TYPE_NUMCHOICES) {
			mxSetField(plhs[0], 0, field_list[0], mxCreateString(
				MCTG_HW_TYPE_NAMES[m_mctdCurrentState.uHardwareType]));
		} 
		else {
			mxSetField(plhs[0], 0, field_list[0], mxCreateString("invalid"));
		}

		// amplifier channel
		mxSetField(plhs[0], 0, field_list[1], mxCreateDoubleScalar(
			(double) m_mctdCurrentState.uChannelID));

		// operating mode
		if (m_mctdCurrentState.uOperatingMode < MCTG_MODE_NUMCHOICES) {
			mxSetField(plhs[0], 0, field_list[2], mxCreateString(
				MCTG_MODE_NAMES[m_mctdCurrentState.uOperatingMode]));
		} 
		else {
			mxSetField(plhs[0], 0, field_list[2], mxCreateString("invalid"));
		}
		
		// output gain (alpha)
		mxSetField(plhs[0], 0, field_list[3], mxCreateDoubleScalar(
			m_mctdCurrentState.dAlpha));
		
		// scaled output signal
		if (m_mctdCurrentState.uScaledOutSignal < MCTG_OUT_MUX_NUMCHOICES) {
			switch (m_mctdCurrentState.uOperatingMode) {
			case MCTG_MODE_VCLAMP:
				mxSetField(plhs[0], 0, field_list[4], mxCreateString(
					MCTG_OUT_MUX_VC_SHORT_NAMES[m_mctdCurrentState.uScaledOutSignal]));
				break;
			case MCTG_MODE_ICLAMP:
			case MCTG_MODE_ICLAMPZERO:
				mxSetField(plhs[0], 0, field_list[4], mxCreateString(
					MCTG_OUT_MUX_IC_SHORT_NAMES[m_mctdCurrentState.uScaledOutSignal]));
				break;
			default:
				mxSetField(plhs[0], 0, field_list[4], mxCreateString("invalid mode"));
				break;
			}
		} 
		else {
			mxSetField(plhs[0], 0, field_list[4], mxCreateString("invalid"));
		}
		
		// scaled output gain & units
		// include product with output gain
		// account for output gain > 1000
		output_gain = m_mctdCurrentState.dScaleFactor * m_mctdCurrentState.dAlpha;
		switch (m_mctdCurrentState.uScaleFactorUnits) {
		case MCTG_UNITS_VOLTS_PER_VOLT:
			if (output_gain > 1000.0) {
				output_gain /= 1000.0;
			}
			else {
				mxSetField(plhs[0], 0, field_list[6], mxCreateString("V/V")); 
				break;
			}
		case MCTG_UNITS_VOLTS_PER_MILLIVOLT:
			if (output_gain > 1000.0) {
				output_gain /= 1000.0;
			}
			else {
				mxSetField(plhs[0], 0, field_list[6], mxCreateString("V/mV")); 
				break;
			}
		case MCTG_UNITS_VOLTS_PER_MICROVOLT:
			mxSetField(plhs[0], 0, field_list[6], mxCreateString("V/uV")); 
			break;
		case MCTG_UNITS_VOLTS_PER_AMP:
			if (output_gain > 1000.0) {
				output_gain /= 1000.0;
			}
			else {
				mxSetField(plhs[0], 0, field_list[6], mxCreateString("V/A")); 
				break;
			}
		case MCTG_UNITS_VOLTS_PER_MILLIAMP:
			if (output_gain > 1000.0) {
				output_gain /= 1000.0;
			}
			else {
				mxSetField(plhs[0], 0, field_list[6], mxCreateString("V/mA")); 
				break;
			}
		case MCTG_UNITS_VOLTS_PER_MICROAMP:
			if (output_gain > 1000.0) {
				output_gain /= 1000.0;
			}
			else {
				mxSetField(plhs[0], 0, field_list[6], mxCreateString("V/uA")); 
				break;
			}
		case MCTG_UNITS_VOLTS_PER_NANOAMP:
			if (output_gain > 1000.0) {
				output_gain /= 1000.0;
			}
			else {
				mxSetField(plhs[0], 0, field_list[6], mxCreateString("V/nA")); 
				break;
			}
		case MCTG_UNITS_VOLTS_PER_PICOAMP:
			mxSetField(plhs[0], 0, field_list[6], mxCreateString("V/pA")); 
			break;
		default:
			mxSetField(plhs[0], 0, field_list[6], mxCreateString("invalid")); 
			break;
		}
		mxSetField(plhs[0], 0, field_list[5], mxCreateDoubleScalar(output_gain));
		
		// raw output signal
		if (m_mctdCurrentState.uRawOutSignal < MCTG_OUT_MUX_NUMCHOICES) {
			switch (m_mctdCurrentState.uOperatingMode) {
			case MCTG_MODE_VCLAMP:
				mxSetField(plhs[0], 0, field_list[7], mxCreateString(
					MCTG_OUT_MUX_VC_SHORT_NAMES[m_mctdCurrentState.uRawOutSignal]));
				break;
			case MCTG_MODE_ICLAMP:
			case MCTG_MODE_ICLAMPZERO:
				mxSetField(plhs[0], 0, field_list[7], mxCreateString(
					MCTG_OUT_MUX_IC_SHORT_NAMES[m_mctdCurrentState.uRawOutSignal]));
				break;
			default:
				mxSetField(plhs[0], 0, field_list[7], mxCreateString("invalid mode"));
				break;
			}
		} 
		else {
			mxSetField(plhs[0], 0, field_list[7], mxCreateString("invalid"));
		}
		
		// raw output gain & units
		// not scaled by output gain
		mxSetField(plhs[0], 0, field_list[8], mxCreateDoubleScalar(
			m_mctdCurrentState.dRawScaleFactor));
		switch (m_mctdCurrentState.uRawScaleFactorUnits) {
		case MCTG_UNITS_VOLTS_PER_VOLT:
			mxSetField(plhs[0], 0, field_list[9], mxCreateString("V/V")); 
			break;
		case MCTG_UNITS_VOLTS_PER_MILLIVOLT:
			mxSetField(plhs[0], 0, field_list[9], mxCreateString("V/mV")); 
			break;
		case MCTG_UNITS_VOLTS_PER_MICROVOLT:
			mxSetField(plhs[0], 0, field_list[9], mxCreateString("V/uV")); 
			break;
		case MCTG_UNITS_VOLTS_PER_AMP:
			mxSetField(plhs[0], 0, field_list[9], mxCreateString("V/A")); 
			break;
		case MCTG_UNITS_VOLTS_PER_MILLIAMP:
			mxSetField(plhs[0], 0, field_list[9], mxCreateString("V/mA")); 
			break;
		case MCTG_UNITS_VOLTS_PER_MICROAMP:
			mxSetField(plhs[0], 0, field_list[9], mxCreateString("V/uA")); 
			break;
		case MCTG_UNITS_VOLTS_PER_NANOAMP:
			mxSetField(plhs[0], 0, field_list[9], mxCreateString("V/nA")); 
			break;
		case MCTG_UNITS_VOLTS_PER_PICOAMP:
			mxSetField(plhs[0], 0, field_list[9], mxCreateString("V/pA")); 
			break;
		default:
			mxSetField(plhs[0], 0, field_list[9], mxCreateString("unknown")); 
			break;
		}
		
		// LPF cutoff frequency and units
		// set frequency to Inf if bypass
		if (m_mctdCurrentState.dLPFCutoff >= MCTG_LPF_BYPASS) {
			mxSetField(plhs[0], 0, field_list[10], mxCreateDoubleScalar(mxGetInf()));
			mxSetField(plhs[0], 0, field_list[11], mxCreateString("Hz")); 
		}
		else if (m_mctdCurrentState.dLPFCutoff >= 1000.0) {
			mxSetField(plhs[0], 0, field_list[10], mxCreateDoubleScalar(
				m_mctdCurrentState.dLPFCutoff / 1000.0));
			mxSetField(plhs[0], 0, field_list[11], mxCreateString("kHz")); 
		}
		else {
			mxSetField(plhs[0], 0, field_list[10], mxCreateDoubleScalar(
				m_mctdCurrentState.dLPFCutoff));
			mxSetField(plhs[0], 0, field_list[11], mxCreateString("Hz")); 
		}
		
		// membrane capacitance and units
		// set capacitance to zero if compensation not on
		if (m_mctdCurrentState.dMembraneCap == MCTG_NOMEMBRANECAP) {
			mxSetField(plhs[0], 0, field_list[12], mxCreateDoubleScalar(0.0));
			mxSetField(plhs[0], 0, field_list[13], mxCreateString("pF")); 
		}
		else if (m_mctdCurrentState.dMembraneCap >= 1.0e-6) {
			mxSetField(plhs[0], 0, field_list[12], mxCreateDoubleScalar(
				m_mctdCurrentState.dMembraneCap * 1.0e6));
			mxSetField(plhs[0], 0, field_list[13], mxCreateString("uF")); 
		}
		else if (m_mctdCurrentState.dMembraneCap >= 1.0e-9) {
			mxSetField(plhs[0], 0, field_list[12], mxCreateDoubleScalar(
				m_mctdCurrentState.dMembraneCap * 1.0e9));
			mxSetField(plhs[0], 0, field_list[13], mxCreateString("nF")); 
		}
		else {
			mxSetField(plhs[0], 0, field_list[12], mxCreateDoubleScalar(
				m_mctdCurrentState.dMembraneCap * 1.0e12));
			mxSetField(plhs[0], 0, field_list[13], mxCreateString("pF")); 
		}
		
		// external command sensitivity and units
		// set to zero if external command is off
		switch (m_mctdCurrentState.uOperatingMode) {
		case MCTG_MODE_VCLAMP:
			if (m_mctdCurrentState.dExtCmdSens <= 0.0) {
				mxSetField(plhs[0], 0, field_list[14], mxCreateDoubleScalar(0.0));
				mxSetField(plhs[0], 0, field_list[15], mxCreateString("uV/V")); 
			}
			else if (m_mctdCurrentState.dExtCmdSens < 1.0e-3) {
				mxSetField(plhs[0], 0, field_list[14], mxCreateDoubleScalar(
					m_mctdCurrentState.dExtCmdSens * 1.0e6));
				mxSetField(plhs[0], 0, field_list[15], mxCreateString("uV/V")); 
			}
			else if (m_mctdCurrentState.dExtCmdSens < 1.0) {
				mxSetField(plhs[0], 0, field_list[14], mxCreateDoubleScalar(
					m_mctdCurrentState.dExtCmdSens * 1.0e3));
				mxSetField(plhs[0], 0, field_list[15], mxCreateString("mV/V")); 
			}
			else {
				mxSetField(plhs[0], 0, field_list[14], mxCreateDoubleScalar(
					m_mctdCurrentState.dExtCmdSens));
				mxSetField(plhs[0], 0, field_list[15], mxCreateString("V/V")); 
			}
			break;
		case MCTG_MODE_ICLAMP:
		case MCTG_MODE_ICLAMPZERO:
			if (m_mctdCurrentState.dExtCmdSens <= 0.0) {
				mxSetField(plhs[0], 0, field_list[14], mxCreateDoubleScalar(0.0));
				mxSetField(plhs[0], 0, field_list[15], mxCreateString("pA/V")); 
			}
			else if (m_mctdCurrentState.dExtCmdSens < 1.0e-9) {
				mxSetField(plhs[0], 0, field_list[14], mxCreateDoubleScalar(
					m_mctdCurrentState.dExtCmdSens * 1.0e12));
				mxSetField(plhs[0], 0, field_list[15], mxCreateString("pA/V")); 
			}
			else if (m_mctdCurrentState.dExtCmdSens < 1.0e-6) {
				mxSetField(plhs[0], 0, field_list[14], mxCreateDoubleScalar(
					m_mctdCurrentState.dExtCmdSens * 1.0e9));
				mxSetField(plhs[0], 0, field_list[15], mxCreateString("nA/V")); 
			}
			else {
				mxSetField(plhs[0], 0, field_list[14], mxCreateDoubleScalar(
					m_mctdCurrentState.dExtCmdSens * 1.0e6));
				mxSetField(plhs[0], 0, field_list[15], mxCreateString("uA/V")); 
			}
			break;
		default:
			mxSetField(plhs[0], 0, field_list[14], mxCreateDoubleScalar(0.0));
			mxSetField(plhs[0], 0, field_list[15], mxCreateString("unknown")); 
			break;
		}

		destroy_2D_array(field_list, FIELD_COUNT);
	}

	// output is [] if not successful
	else {
		plhs[0] = mxCreateDoubleMatrix(0, 0, mxREAL);
	}
	
	// provide excess outputs if specified
	for (i = 1; i < nlhs; i++) {
		plhs[i] = mxCreateDoubleMatrix(0, 0, mxREAL);
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
		
	case WM_TIMER:		// telegraph connection timed out
		if (wParam == s_cuConnectionTimerEventID) {
			m_bIsConnecting = FALSE;
			KillTimer(hWnd, s_cuConnectionTimerEventID);
			if (!m_bIsConnected) {
				mexWarnMsgTxt("telegraph connection timed out");
				m_bIsError = TRUE;
				DestroyWindow(hWnd);
			}
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
				
				// we have the info we need
				// can disconnect & kill window
				m_bIsUpdated = TRUE;
				DestroyWindow(hWnd);
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


// create 2D array
char **create_2D_array(int nstring, int nchar) {

	// declarations
	char	**char_array;	// output pointer
	int		i;				// loop counter

	// allocate array storage
	char_array = (char **) mxMalloc((size_t) nstring * sizeof(char *));
	for (i = 0; i < nstring; i++) {
		char_array[i] = (char *) mxCalloc((size_t) nchar, sizeof(char));
	}
	return(char_array);
}


// free 2D array
void destroy_2D_array(char **char_array, int nstring) {

	// declarations
	int		i;				// loop counter

	// deallocate array storage
	for (i = 0; i < nstring; i++) {
		mxFree((void *) char_array[i]);
	}
	mxFree((void *) char_array);
}

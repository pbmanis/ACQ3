function quick(arg)

global MCList HARDWARE AmpStatus

AmpStatus = telegraph; %  read the amplifier status first 
dual = 0;
if (arg > 3)
    dual = 1;
end;

switch(arg)
    case {1,4}
        acq_stop;
        switch(lower(HARDWARE.InputDevice1.Amplifier))
            case MCList
               if(dual)
                   g s2
               else
                   g s
               end;
               scope
            otherwise
                if(AmpStatus.Mode == 'V' || AmpStatus.Mode == '0')
                    if(dual)
                        g s2
                    else
                        g s
                    end;
                    scope
                else
                    QueMessage('Unable to load: Amplfier is not in VClamp', 1);
                end;
        end;

    case {2,5}
        acq_stop;
        switch(lower(HARDWARE.InputDevice1.Amplifier))
            case MCList
                if(dual)
                    g i2
                else
                    g i
                end;
                scope
            otherwise
                if(AmpStatus.Mode == 'V' || AmpStatus.Mode == '0')
                    if(dual)
                        g i2
                    else
                        g i
                    end;
                    
                    scope
                else
                    QueMessage('Unable to load: Amplfier is not in VClamp', 1);
                end;
        end;

    case {3,6}
        acq_stop;

        switch(lower(HARDWARE.InputDevice1.Amplifier))
            case MCList % can handle automatic switching.
                if(dual)
                    g cci2
                else
                    g cci
                end;
                scope
            otherwise
                if(AmpStatus.Mode == 'I' || AmpStatus.Mode == '0')
                    if(dual)
                        g cci2
                    else
                        g cci
                    end;
                    scope
                else
                    QueMessage('Unable to load: Amplfier is not in IClamp', 1);
                end;
        end;
    otherwise
        % do nothing
        return;
end;
return;

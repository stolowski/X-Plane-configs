if(PLANE_ICAO == "B738") then
    dataref("SHARED_0", "SRS/X-KeyPad/SharedInt", "writable", 0) -- Strobe lights control
    dataref("SHARED_1", "SRS/X-KeyPad/SharedInt", "writable", 1) -- Transponder mode control
    dataref("SHARED_2", "SRS/X-KeyPad/SharedInt", "writable", 2) -- Autobrakes control 

    --- real state in the cockpit
    dataref("StrobeLights", "laminar/B738/toggle_switch/position_light_pos", "readonly")
    dataref("TransponderMode", "laminar/B738/knob/transponder_pos", "readonly")
    dataref("RadioAlt", "sim/cockpit2/gauges/indicators/radio_altimeter_height_ft_pilot", "readonly")
    dataref("AutoBrakes", "laminar/B738/autobrake/autobrake_pos", "readonly")

    SHARED_0 = StrobeLights
    LAST_SHARED_0 = SHARED_0
        
    SHARED_1 = TransponderMode
    LAST_SHARED_1 = SHARED_1

    SHARED_2 = 0
    LAST_SHARED_2 = SHARED_2

    local brakesDir = 1

    --[[ function checkStrobeLights()
        if (SHARED_0 ~= LAST_SHARED_0) then
            if (StrobeLights < 1) then
                command_once("laminar/B738/toggle_switch/position_light_up")
            else
                if (StrobeLights == 1) then
                    command_once("laminar/B738/toggle_switch/position_light_down")
                end
            end
            LAST_SHARED_0 = SHARED_0
        end
    end
 ]]
    function checkStrobeLights()
        if SHARED_0 == LAST_SHARED_0 then
            LAST_SHARED_0 = StrobeLights
            SHARED_0 = LAST_SHARED_0
        else
            if StrobeLights >  SHARED_0 then
				command_once("laminar/B738/toggle_switch/position_light_down")
			else
				if StrobeLights <  SHARED_0 then
					command_once("laminar/B738/toggle_switch/position_light_up")
				end
			end
            if StrobeLights == SHARED_0 then
                LAST_SHARED_0 = SHARED_0
            end
        end
    end

    function checkAutobrakes()
        if (SHARED_2 ~= LAST_SHARED_2) then
            if (RadioAlt > 10) then
                if (AutoBrakes <= 1) then
                    if (brakesDir < 0) then
                        brakesDir = 1
                    end
                end
                if (AutoBrakes > 4) then
                    if (brakesDir > 0) then
                        brakesDir = -1
                    end
                end
                if (brakesDir < 0) then
                    command_once("laminar/B738/knob/autobrake_dn")
                else
                    command_once("laminar/B738/knob/autobrake_up")
                end
            else
                if (AutoBrakes == 0) then
                    command_once("laminar/B738/knob/autobrake_up")
                else
                    command_once("laminar/B738/knob/autobrake_dn")
                end
            end
            LAST_SHARED_2 = SHARED_2
        end
    end


    function checkTransponderMode()
        if SHARED_1 == LAST_SHARED_1 then
            LAST_SHARED_1 = TransponderMode
            SHARED_1 = LAST_SHARED_1
        else
            if TransponderMode >  SHARED_1 then
				command_once("laminar/B738/knob/transponder_mode_dn")
			else
				if TransponderMode <  SHARED_1 then
					command_once("laminar/B738/knob/transponder_mode_up")
				end
			end
            if TransponderMode == SHARED_1 then
                LAST_SHARED_1 = SHARED_1
            end
        end
    end

    do_every_frame("checkStrobeLights()")
    do_every_frame("checkTransponderMode()")
    do_every_frame("checkAutobrakes()")
end
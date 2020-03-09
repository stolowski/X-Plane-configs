if(PLANE_ICAO == "A320") then
    dataref("SHARED_0", "SRS/X-KeyPad/SharedInt", "readable", 0)  -- Auto brake trigger

    dataref("Autobrk_Red_Led", "SRS/X-KeyPad/red_leds", "writable", 23)
    dataref("Autobrk_Blue_Led", "SRS/X-KeyPad/blue_leds", "writable", 23)
    dataref("Warn_Blue_Led", "SRS/X-KeyPad/blue_leds", "writable", 22)
    dataref("Warn_Red_Led", "SRS/X-KeyPad/red_leds", "writable", 22)

    --- real state in the cockpit
    dataref("BrakeLow", "a320/Panel/BrakeAuto1", "readable")	
    dataref("BrakeMed", "a320/Panel/BrakeAuto2", "readable")
    dataref("BrakeMax", "a320/Panel/BrakeAuto3", "readable")
    dataref("RadioAlt", "sim/cockpit2/gauges/indicators/radio_altimeter_height_ft_pilot", "readable")

    dataref("MasterCaution", "a320/Panel/ShieldMastCautL", "readable")
    dataref("MasterWarn", "a320/Panel/ShieldMastWarnL", "readable")

    -- init
    SHARED_0 = 0
    LAST_SHARED_0 = 0

    function checkAutobrakes()
        if (SHARED_0 ~= LAST_SHARED_0) then
            -- Led state values
		    local off = 0
		    local on = 1
		    local blink = 2
            if (RadioAlt > 10) then
                if (BrakeLow > 0) then
                    command_once("a320/Panel/BrakeAuto2_button")
                    Autobrk_Red_Led = on
                    Autobrk_Blue_Led = off
                else
                    if (BrakeMed > 0) then
                        -- off
                        command_once("a320/Panel/BrakeAuto2_button")
                        Autobrk_Red_Led = off
                        Autobrk_Blue_Led = off
                    else
                        command_once("a320/Panel/BrakeAuto1_button")
                        Autobrk_Red_Led = off
                        Autobrk_Blue_Led = on
                    end
                end
            else
               -- toggles max/off
               command_once("a320/Panel/BrakeAuto3_button")
               Autobrk_Red_Led = blink
               Autobrk_Blue_Led = blink
            end
            LAST_SHARED_0 = SHARED_0
        end
    end

    function checkCautionWarn()
        if MasterCaution > 0 or MasterWarn > 0 then
            Warn_Red_Led = 2 -- blink
            Warn_Blue_Led = 0
        else
            Warn_Red_Led = 0
            Warn_Blue_Led = 1
        end
    end
    
    do_often("checkAutobrakes()")
    do_often("checkCautionWarn()")
end
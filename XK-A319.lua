if(PLANE_ICAO == "A319") then
    dataref("SHARED_0", "SRS/X-KeyPad/SharedInt", "readable", 0)  -- Auto brake trigger
    dataref("TransponderCode", "SRS/X-KeyPad/SharedInt", "readable", 1)

    dataref("Autobrk_Red_Led", "SRS/X-KeyPad/red_leds", "writable", 23)
    dataref("Autobrk_Blue_Led", "SRS/X-KeyPad/blue_leds", "writable", 23)

    --- real state in the cockpit
    dataref("BrakeLow", "AirbusFBW/AutoBrkLo", "readable")	
    dataref("BrakeMed", "AirbusFBW/AutoBrkMed", "readable")
    dataref("BrakeMax", "AirbusFBW/AutoBrkMax", "readable")
    dataref("RadioAlt", "sim/cockpit2/gauges/indicators/radio_altimeter_height_ft_pilot", "readable")

    dataref("XPDR1", "AirbusFBW/XPDR1", "writable")
    dataref("XPDR2", "AirbusFBW/XPDR2", "writable")	
    dataref("XPDR3", "AirbusFBW/XPDR3", "writable")	
    dataref("XPDR4", "AirbusFBW/XPDR4", "writable")	

    -- init
    SHARED_0 = 0
    LAST_SHARED_0 = 0
    LAST_XPDR_CODE = TransponderCode

    function checkAutobrakes()
        if (SHARED_0 ~= LAST_SHARED_0) then
            -- Led state values
		    local off = 0
		    local on = 1
		    local blink = 2
            if (RadioAlt > 10) then
                if (BrakeLow > 0) then
                    command_once("AirbusFBW/AbrkMed")
                    Autobrk_Red_Led = on
                    Autobrk_Blue_Led = off
                else
                    if (BrakeMed > 0) then
                        -- off
                        command_once("AirbusFBW/AbrkMed")
                        Autobrk_Red_Led = off
                        Autobrk_Blue_Led = off
                    else
                        command_once("AirbusFBW/AbrkLo")
                        Autobrk_Red_Led = off
                        Autobrk_Blue_Led = on
                    end
                end
            else
               -- toggles max/off
               command_once("AirbusFBW/AbrkMax")
               Autobrk_Red_Led = blink
               Autobrk_Blue_Led = blink
            end
            LAST_SHARED_0 = SHARED_0
        end
    end

    function checkTransponder()
        if LAST_XPDR_CODE ~= TransponderCode then
            local val, val2
            val = math.floor(TransponderCode/10)
            XPDR1 = TransponderCode - 10*val
            val2 = math.floor(val/10)
            XPDR2 = val - 10*val2
            val = math.floor(val2/10)
            XPDR3 = val2 - 10*val
            val2 = math.floor(val/10)
            XPDR4 =  val - 10*val2
            LAST_XPDR_CODE = TransponderCode
        end
    end 

    do_often("checkAutobrakes()")
    do_often("checkTransponder()")

    create_command("A319/toggle_bcn_lights", "Toggle beacon lights",
        [[ref = XPLMFindDataRef("AirbusFBW/OHPLightSwitches")
        if ref ~= nil then
          val = XPLMGetDatavi(ref, 0, 1)
          val[0] = 1-val[0]
          XPLMSetDatavi(ref, val, 0, 1)
        end ]], "", "")

    create_command("A319/toggle_strobe_lights", "Toggle strobe lights",
        [[ref = XPLMFindDataRef("AirbusFBW/OHPLightSwitches")
        if ref ~= nil then
          val = XPLMGetDatavi(ref, 0, 8)
          val[7] = val[7] + 1
          if val[7] > 2 then
            val[7] = 0
          end
          XPLMSetDatavi(ref, val, 0, 8)
        end ]], "", "")

    create_command("A319/toggle_nav_lights", "Toggle nav lights",
        [[ref = XPLMFindDataRef("AirbusFBW/OHPLightSwitches")
        if ref ~= nil then
          val = XPLMGetDatavi(ref, 0, 3)
          val[2] = val[2]+1
          if val[2] > 2 then
            val[2] = 0
          end
          XPLMSetDatavi(ref, val, 0, 3)
        end ]], "", "")

    create_command("A319/toggle_nose_lights", "Toggle nose lights",
        [[ref = XPLMFindDataRef("AirbusFBW/OHPLightSwitches")
        if ref ~= nil then
          val = XPLMGetDatavi(ref, 0, 4)
          val[3] = val[3]+1
          if val[3] > 2 then
            val[3] = 0
          end
          XPLMSetDatavi(ref, val, 0, 4)
        end ]], "", "")


    create_command("A319/toggle_land_lights", "Toggle landing lights",
        [[ref = XPLMFindDataRef("AirbusFBW/OHPLightSwitches")
        if ref ~= nil then
          val = XPLMGetDatavi(ref, 0, 6)
          val[4] = val[4] + 1
          if val[4] > 2 then
            val[4] = 0
          end
          val[5]=val[4]
          XPLMSetDatavi(ref, val, 0, 6)
        end ]], "", "")

    create_command("A319/inc_ND_range", "Increase ND range",
        [[ref = XPLMFindDataRef("AirbusFBW/NDrangeCapt")
        if ref ~= nil then
          val = XPLMGetDatai(ref)
          if (val < 5) then
                val = val + 1
          end
          XPLMSetDatai(ref, val)
        end ]], "", "")

    create_command("A319/dec_ND_range", "Decrease ND range",
        [[ref = XPLMFindDataRef("AirbusFBW/NDrangeCapt")
        if ref ~= nil then
          val = XPLMGetDatai(ref)
          if (val > 0) then
                val = val - 1
          end
          XPLMSetDatai(ref, val)
        end ]], "", "")

    create_command("A319/inc_ND_mode", "Increase ND mode",
        [[ref = XPLMFindDataRef("AirbusFBW/NDmodeCapt")
        if ref ~= nil then
          val = XPLMGetDatai(ref)
          if (val < 4) then
                val = val + 1
          end
          XPLMSetDatai(ref, val)
        end ]], "", "")

    create_command("A319/dec_ND_mode", "Decrease ND mode",
        [[ref = XPLMFindDataRef("AirbusFBW/NDmodeCapt")
        if ref ~= nil then
          val = XPLMGetDatai(ref)
          if (val > 0) then
                val = val - 1
          end
          XPLMSetDatai(ref, val)
        end ]], "", "")

    create_command("A319/transponder_Mode", "Advance transponder mode",
        [[ref = XPLMFindDataRef("AirbusFBW/XPDRPower")
        if ref ~= nil then
          val = XPLMGetDatai(ref)
          if (val < 4) then
                val = val + 1
          else
                val = 0
          end
          XPLMSetDatai(ref, val)
        end ]], "", "")

    create_command("A319/toggle_AP", "Toggle Autopilot",
        [[ref = XPLMFindDataRef("AirbusFBW/AP1Engage")
        if ref ~= nil then
          val = XPLMGetDatavi(ref, 0, 1)
          val[0] = 1-val[0]
          XPLMSetDatavi(ref, val, 0, 1)
        end ]], "", "")
end
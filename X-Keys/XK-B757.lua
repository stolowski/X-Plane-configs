if(PLANE_ICAO == "B752") then
    dataref("SHARED_0", "SRS/X-KeyPad/SharedInt", "readable", 0)  -- altimeter
    dataref("SHARED_1", "SRS/X-KeyPad/SharedInt", "readable", 1)  -- vor1 crs up
    dataref("SHARED_2", "SRS/X-KeyPad/SharedInt", "readable", 2)  -- vor1 crs down
    dataref("SHARED_3", "SRS/X-KeyPad/SharedInt", "readable", 3)  -- vor2 crs up
    dataref("SHARED_4", "SRS/X-KeyPad/SharedInt", "readable", 4)  -- vor2 crs up

    dataref("SHARED_5", "SRS/X-KeyPad/SharedInt", "writable", 5)  -- crs1 trigger

    dataref("Vor1CRS", "1-sim/vor1/crsRotary", "writable")
    dataref("Vor2CRS", "1-sim/vor2/crsRotary", "writable")
    --1-sim/ils/crsBigRotary

    -- real state in the sim
    dataref("Barometer", "sim/cockpit/misc/barometer_setting", "readable")
    dataref("CRS1", "sim/cockpit/radios/nav1_obs_degm", "readable")
    dataref("BarometerAnim", "1-sim/ng/baroSmallL/anim", "writable")

    -- init
    LAST_SHARED_0 = SHARED_0
    LAST_SHARED_1 = SHARED_1
    LAST_SHARED_2 = SHARED_2
    LAST_SHARED_3 = SHARED_3
    LAST_SHARED_4 = SHARED_4
    LAST_SHARED_5 = SHARED_5
    lastBaro = 0
    targetCRS1 = -1

    function sync757()
        if SHARED_1 ~= LAST_SHARED_1 then
            Vor1CRS = Vor1CRS + 0.01
            LAST_SHARED_1 = SHARED_1
        end
        if SHARED_2 ~= LAST_SHARED_2 then
            Vor1CRS = Vor1CRS - 0.01
            LAST_SHARED_2 = SHARED_2
        end
        if SHARED_3 ~= LAST_SHARED_3 then
            Vor2CRS = Vor2CRS + 0.01
            LAST_SHARED_3 = SHARED_3
        end
        if SHARED_4 ~= LAST_SHARED_4 then
            Vor2CRS = Vor2CRS - 0.01
            LAST_SHARED_4 = SHARED_4
        end

        -- crs1 set trigger
        if SHARED_5 ~= LAST_SHARED_5 and SHARED_5 > 0 then
            targetCRS1 = SHARED_5
            LAST_SHARED_5 = 0
            SHARED_5 = 0
        end
        -- triggered multiple times (on every frame) until target course is reached
        if targetCRS1 > 0 then
            target = targetCRS1
            source = CRS1
            if target == source then
                -- reset target course (disables the looping)
                targetCRS1 = 0
            else
                if target > source then
                    distLeft = source + 361 - target
                    distRight = target - source
                else
                    distLeft = source - target
                    distRight = 361 - source + target
                end
                if distLeft > distRight then
                    Vor1CRS = Vor1CRS + 0.01
                else
                    Vor1CRS = Vor1CRS - 0.01
                end
            end
        end

        if (SHARED_0 ~= LAST_SHARED_0) then
            targetBaro = SHARED_0
            currentBaro = math.floor((Barometer + 0.005) * 100)

            -- kludge: STD mode cannot be detected and baro value doesn't
            -- change as we rotate the knob. Detect this and stop rotating.
            if Barometer == lastBaro then
                LAST_SHARED_0 = SHARED_0
                return
            end

            -- safety
            if math.abs(targetBaro - currentBaro) > 200 then
                LAST_SHARED_0 = SHARED_0
                return
            end
            --print(targetBaro)
            --print(currentBaro)
            --print(Barometer)
            --print("-")

            if currentBaro > targetBaro then
                BarometerAnim = BarometerAnim - 1
            elseif currentBaro < targetBaro then
                BarometerAnim = BarometerAnim + 1
            end
            lastBaro = Barometer

            if currentBaro == targetBaro then
                LAST_SHARED_0 = SHARED_0
                lastBaro = 0
                return
            end

        end
    end

    do_every_frame("sync757()")
end
if(PLANE_ICAO == "B752") then
    dataref("SHARED_0", "SRS/X-KeyPad/SharedInt", "readable", 0)  -- altimeter

    -- real state in the sim
    dataref("Barometer", "sim/cockpit/misc/barometer_setting", "readable")
    dataref("BarometerAnim", "1-sim/ng/baroSmallL/anim", "writable")

    -- init
    LAST_SHARED_0 = SHARED_0
    lastBaro = 0

    function syncAltimeter()
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

    do_every_frame("syncAltimeter()")
end
function [xout, yout] = newpoint(xin, yin, pos)
    if pos == 1
        xout = xin - 1;
        yout = yin - 1;
    elseif pos == 2
        xout = xin;
        yout = yin - 1;
    elseif pos == 3
        xout = xin + 1;
        yout = yin - 1;
    elseif pos == 4
        xout = xin - 1;
        yout = yin;
    elseif pos == 5
        xout = xin;
        yout = yin;
    elseif pos == 6
        xout = xin + 1;
        yout = yin;
    elseif pos == 7
        xout = xin - 1;
        yout = yin + 1;
    elseif pos == 8
        xout = xin;
        yout = yin + 1;
    elseif pos == 9
        xout = xin + 1;
        yout = yin + 1;
    end
        
    if (xout <1)
        xout = 1;
    end
    if (yout < 1 )
        yout = 1;
    end
end
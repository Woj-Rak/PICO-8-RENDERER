M_PI = 3.1415926535898

function lerp(a,b,alpha)
    return a*(1.0-alpha)+b*alpha
end

function degtorad(x)
    return x * (M_PI/180);
end

function bettersin(radians) 
    return -sin(radians/M_PI/2);
end

function bettercos(radians) 
    return cos(radians/M_PI/2);
end

function bettertan(radians)
    return bettersin(radians) / bettercos(radians);
end
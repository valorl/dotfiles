def qdecimal(d): (
    if d == null then null
    else
        (d.SignScale // 0) as $ss |
        ($ss / 65536 | floor) as $scale |
        (pow(10; $scale) // 1) as $divisor |
        if $divisor == 0 then (d.lo | tonumber) else (d.lo | tonumber) / $divisor end
    end
);

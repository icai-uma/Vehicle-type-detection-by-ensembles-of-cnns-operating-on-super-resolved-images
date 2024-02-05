function esta = enLimites(limites,tam)

esta = 0;
if (limites(1) <= 0) || ((limites(1)+limites(3)) >= tam(1)) || ...
   (limites(2) <= 0) || ((limites(2)+limites(4)) >= tam(2))
    esta = 1;
end


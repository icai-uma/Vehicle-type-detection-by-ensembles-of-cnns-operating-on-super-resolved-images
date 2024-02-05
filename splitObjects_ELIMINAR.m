function L = splitObjects_ELIMINAR(bd)

D = bwdist(~bd);
D = -D;
D(~bd) = -Inf;
L = watershed(D);

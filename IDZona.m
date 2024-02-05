function id = IDZona(model,c)

puntos = [model.zonas.Punto];
puntos = [puntos(1:2:end); puntos(2:2:end)]';

[m, pos] = min(dist(puntos,c'));

id = pos;
function zonas = ZoneDefinition(tam)

DIV_X = 3;
DIV_Y = 3;
ptox = (tam(1) / DIV_X)/2:(tam(1) / DIV_X):tam(1);
ptoy = (tam(2) / DIV_Y)/2:(tam(2) / DIV_Y):tam(2);

cont = 1;
for i=1:DIV_Y
    for j=1:DIV_X
        zonas(cont).ID = cont;
        zonas(cont).Punto = [ptoy(i) ptox(j)];
        zonas(cont).MediaArea = [];
        zonas(cont).VarianzaArea = [];
        zonas(cont).MediaDim = [];
        zonas(cont).VarianzaDim = [];
        cont = cont + 1;
    end
end

function matriz_bin = obtenerCorrespondenciaDistancia(matriz,r)

% que follon!!!!!!!!!!!
RADIO = 50;
if nargin > 1
    RADIO = r;
end
matriz2 = matriz;
matriz_local = matriz2;

% Inicializamos la matriz de salida a todo 0
matriz_bin = zeros(size(matriz2));

% Realizamos un proceso iterativo hasta que nos quedemos con una matriz de
% una fila o una columna
while all(size(matriz_local) > 1)
    % Calculamos el minimo y obtenemos su posicion dentro de la matriz
    % original
    matriz_bin_temp = double(min(min(matriz_local)) == matriz2);
    
    % Calculamos el minimo y obtenemos su posicion dentro de la matriz
    % local
    matriz_bin_find = double(min(min(matriz_local)) == matriz_local);
    
    % Buscamos la posicion del minimo y nos quedamos con otra matriz en la
    % que eliminamos la fila y la columna donde esta el mínimo
    [f,c] = find(matriz_bin_find);
    f = f(1);
    c = c(1);
    m_temp = [matriz_local(1:f(1)-1,:); matriz_local(f(1)+1:end,:)];
    matriz_local = [m_temp(:,1:c(1)-1) m_temp(:,c(1)+1:end)];

    % De la matriz inicial, "desactivamos" los valores de la fila y columna
    % del minimo
    [f,c] = find(matriz_bin_temp);
    matriz2(f,:) = -1;
    matriz2(:,c) = -1;
    
    % Vamos almacenando los resultados
    matriz_bin = matriz_bin + matriz_bin_temp;
end

matriz_bin = double(matriz_bin + double(min(min(matriz_local)) == matriz2) > 0);
matriz_bin = (matriz <= RADIO).*matriz_bin;
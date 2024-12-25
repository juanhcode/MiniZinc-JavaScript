int: n;  % Tamaño de la matriz
int: k;  % Número de nuevas localizaciones a seleccionar
int: v; %Localizaciones establecidas

array[0..n-1, 0..n-1] of int: P;  % Matriz del segmento de población
array[0..n-1, 0..n-1] of int: E;  % Matriz del entorno empresarial

array[1..v] of int: x_coordinate;  % Coordenadas de las filas de las posiciones establecidas
array[1..v] of int: y_coordinate;  % Coordenadas de las columnas de las posiciones establecidas

% Variables de decisión
array[1..k] of var 0..n-1: new_x;  % Coordenadas x de los nuevos programas
array[1..k] of var 0..n-1: new_y;  % Coordenadas y de los nuevos programas

% Lista de deltas para calcular posiciones contiguas (incluye diagonales)
array[1..9] of int: dx = [-1, -1, -1,  0, 1, 1,  1, 0, 0];
array[1..9] of int: dy = [-1,  0,  1,  1, 1, 0, -1, -1, 0];

% Array para almacenar las posiciones contiguas de las nuevas localizaciones
array[1..k, 1..9] of var int: neighbor_x;  % Coordenadas x de las posiciones contiguas
array[1..k, 1..9] of var int: neighbor_y;  % Coordenadas y de las posiciones contiguas

%Suma de las localizaciones establecidas
int: total_sum_P = sum([sum_with_neighbors_old(x_coordinate[i], y_coordinate[i], P) | i in 1..v]);
int: total_sum_E = sum([sum_with_neighbors_old(x_coordinate[i], y_coordinate[i], E) | i in 1..v]);
int: total_sum_old_locations = total_sum_P + total_sum_E;

% Función para verificar si una posición está dentro de la matriz
function bool: is_in_bounds(int: x, int: y) =
    x >= 0 /\ x < n /\ y >= 0 /\ y < n;
    
% Función para verificar si una posición está dentro de la matriz (con variables de decision)
function var bool: is_in_bounds(var int: x, var int: y) =
    x >= 0 /\ x < n /\ y >= 0 /\ y < n;

% Función para sumar la coordenada enviada con sus puntos contiguos
function int: sum_with_neighbors_old(int: x, int: y, array[int, int] of int: matrix) = (
        sum([matrix[x + dx[i], y + dy[i]] | i in 1..9 where is_in_bounds(x + dx[i], y + dy[i])])
    );
% Función para sumar la coordenada enviada con sus puntos contiguos (con variables de decision)
function var int: sum_with_neighbors(var int: x, var int: y, array[int, int] of int: matrix) = (
    sum([matrix[x + dx[i], y + dy[i]] | i in 1..9 where is_in_bounds(x + dx[i], y + dy[i])])
);

% Restricción para calcular las posiciones contiguas y asegurarse de que están dentro de los límites
constraint forall(i in 1..k, j in 1..9)(
    neighbor_x[i, j] = new_x[i] + dx[j] /\
    neighbor_y[i, j] = new_y[i] + dy[j] /\
    is_in_bounds(neighbor_x[i, j], neighbor_y[i, j])
);

% Restricción para asegurar que no haya posiciones contiguas con las localizaciones ya establecidas
constraint forall(i in 1..k, j in 1..9, e in 1..v, m in 1..9)(
    (neighbor_x[i, j] != x_coordinate[e] \/ neighbor_y[i, j] != y_coordinate[e]) /\
    (neighbor_x[i, j] != x_coordinate[e] + dx[m] \/ neighbor_y[i, j] != y_coordinate[e] + dy[m])
);

% Restricción para asegurar que no haya solapamiento entre posiciones contiguas
constraint forall(i, l in 1..k, j in 1..9, m in 1..9 where i != l)(
    (neighbor_x[i, j] != neighbor_x[l, m] \/ neighbor_y[i, j] != neighbor_y[l, m])
);


% Restricción 2: El segmento de población no puede ser menor que 25 en las nuevas localizaciones
constraint forall(i in 1..k)(
    sum([P[new_x[i] + dx[j], new_y[i] + dy[j]] 
        | j in 1..9 where is_in_bounds(new_x[i] + dx[j], new_y[i] + dy[j])]) >= 25
);

% Restricción 3: El entorno empresarial no puede ser menor que 20 en las nuevas localizaciones
constraint forall(i in 1..k)(
    sum([E[new_x[i] + dx[j], new_y[i] + dy[j]] 
        | j in 1..9 where is_in_bounds(new_x[i] + dx[j], new_y[i] + dy[j])]) >= 20
);
    
% Función objetivo: Maximizar la ganancia total de las nuevas localizaciones
var int: total_gain_new = 
    sum(i in 1..k)(
        sum([P[new_x[i] + dx[j], new_y[i] + dy[j]] 
             | j in 1..9 where is_in_bounds(new_x[i] + dx[j], new_y[i] + dy[j])]) +
        sum([E[new_x[i] + dx[j], new_y[i] + dy[j]] 
             | j in 1..9 where is_in_bounds(new_x[i] + dx[j], new_y[i] + dy[j])])
    );

%Suma de las locaciones establecidas mas las locaciones nuevas
var int: sum_old_locations_and_new_locations = total_sum_old_locations + total_gain_new;

% Maximizar la ganancia total
solve maximize total_gain_new;

output [
    show(total_sum_old_locations), "\n",
    show(sum_old_locations_and_new_locations), "\n",
    show(x_coordinate), "\n",
    show(y_coordinate), "\n",
    show(new_x), "\n",
    show(new_y), "\n",
    
];
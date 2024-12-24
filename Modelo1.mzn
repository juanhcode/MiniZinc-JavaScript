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

% Función para verificar si una posición está dentro de la matriz
function bool: is_in_bounds(int: x, int: y) =
    x >= 0 /\ x < n /\ y >= 0 /\ y < n;
    
% Función para verificar si una posición está dentro de la matriz
function var bool: is_in_bounds(var int: x, var int: y) =
    x >= 0 /\ x < n /\ y >= 0 /\ y < n;

% Función para sumar la coordenada enviada con sus puntos contiguos
function int: sum_with_neighbors_old(int: x, int: y, array[int, int] of int: matrix) = (
        sum([matrix[x + dx[i], y + dy[i]] | i in 1..9 where is_in_bounds(x + dx[i], y + dy[i])])
    );
    
int: total_sum_P = sum([sum_with_neighbors_old(x_coordinate[i], y_coordinate[i], P) | i in 1..v]);
int: total_sum_E = sum([sum_with_neighbors_old(x_coordinate[i], y_coordinate[i], E) | i in 1..v]);
int: total_sum_old_locations = total_sum_P + total_sum_E;

function var int: sum_with_neighbors(var int: x, var int: y, array[int, int] of int: matrix) = (
    sum([matrix[x + dx[i], y + dy[i]] | i in 1..9 where is_in_bounds(x + dx[i], y + dy[i])])
);

% Maximizar la ganancia total de las nuevas localizaciones
var int: total_gain = sum([
    (sum_with_neighbors(new_x[i], new_y[i], P) +
     sum_with_neighbors(new_x[i], new_y[i], E))
    | i in 1..k
]);

/*
% Restricción: las nuevas localizaciones no deben ser contiguas (ni la misma posición ni las posiciones contiguas)
constraint forall(i, j in 1..k where i != j)(
    % Las localizaciones no deben solaparse ni ser contiguas
    (abs(new_x[i] - new_x[j]) > 1 \/ abs(new_y[i] - new_y[j]) > 1) /\
    forall(d in 1..9) (
        not (new_x[i] + dx[d] == new_x[j] /\ new_y[i] + dy[d] == new_y[j])
    )
);
*/


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

% Resolver el problema maximizando la ganancia total
solve maximize total_gain;

output [
    "new_x: ", show(new_x), "\n",
    "new_y: ", show(new_y), "\n",
    "total_gain: ", show(total_gain), "\n"
];

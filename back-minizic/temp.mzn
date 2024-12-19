% Definición de variables
var 0..10: x; % Variable x que puede tomar valores entre 0 y 10
var 0..10: y; % Variable y que puede tomar valores entre 0 y 10

% Restricción
constraint x + y = 10; % La suma de x y y debe ser igual a 10

% Buscar una solución
solve satisfy;

% Imprimir la solución
output ["x = " ++ show(x) ++ ", y = " ++ show(y)];
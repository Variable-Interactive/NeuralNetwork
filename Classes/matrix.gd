class_name Matrix
extends RefCounted
## Used to get access to different matrix methods
##
## Godot does not provide matrix functions so this class exists

var _matrix_array: Array[Array]
var _random := RandomNumberGenerator.new()
var _initialized := false

var no_of_rows:  ## making it kinda write protected
	set(value):
		if !_initialized:
			no_of_rows = value
var no_of_columns:  ## making it kinda write protected
	set(value):
		if !_initialized:
			no_of_columns = value


func _init(_rows: int, _columns: int, random := false) -> void:
	no_of_rows = _rows
	no_of_columns = _columns
	if random:
		make_rand_matrix()
	else:
		zero_matrix()
	_initialized = true


func set_index(row: int, col: int, value := 0) -> void:
	if col > no_of_columns:
		printerr("attempting to access column (", col, "), greater than", no_of_columns)
		return
	if row > no_of_rows:
		printerr("attempting to access row (", row, "), greater than", no_of_rows)
		return
	_matrix_array[row - 1][col - 1] = value


func get_index(row: int, col: int) -> float:
	if col > no_of_columns:
		printerr("attempting to access column (", col, "), greater than", no_of_columns)
		return 0
	if row > no_of_rows:
		printerr("attempting to access row (", row, "), greater than", no_of_rows)
		return 0
	return _matrix_array[row - 1][col - 1]


func print_pretty():
	print("printing matrix")
	for row in _matrix_array:
		print(row)


func to_array() -> Array:
	var array := []
	for y in _matrix_array.size():
		for x in _matrix_array.size():
			array.append(_matrix_array[y][x])
	return array


func make_rand_matrix():
	_random.randomize()
	# rows increase top-down so y
	# columns increase from left to right so x
	_matrix_array.clear()
	if no_of_rows < 1 or no_of_columns < 1:
		printerr("Can not create, negative values")
		return
	for _y in range(no_of_rows):
		var r = []
		for _x in range(no_of_columns):
			var value = _random.randfn()
			r.append(value)
		_matrix_array.append(r)


func zero_matrix():
	_matrix_array.clear()
	if no_of_rows < 1 or no_of_columns < 1:
		printerr("Can not create, negative values")
		return
	for _y in range(no_of_rows):
		var r = []
		for _x in range(no_of_columns):
			r.append(0)
		_matrix_array.append(r)


# Operators
func dot(b: Matrix) -> Matrix:
	## check if matrix can be multiplied
	if no_of_columns != b.no_of_rows:
		printerr("Incompatible matrices, can not multiply")
		return Matrix.new(0, 0)
	var matrix = Matrix.new(no_of_rows, b.no_of_columns)
	for i in range(1, no_of_rows + 1):
		for j in range(1, b.no_of_columns + 1):
			for k in range(1, no_of_columns + 1):
				var value = matrix.get_index(i, j) + (get_index(i, k) * b.get_index(k, j))
				matrix.set_index(i, j, value)
	return matrix


func add(b: Matrix) -> Matrix:
	if Vector2i(no_of_rows, no_of_columns) != Vector2i(b.no_of_rows, b.no_of_columns):
		print("Incompatible Matrices, can not add")
		return Matrix.new(0, 0)
	var matrix = Matrix.new(no_of_rows, no_of_columns)
	# this will add 2 (x, 1) matrices
	for row in range(1, no_of_rows):
		for col in range(1, no_of_columns):
			var value = get_index(row, col) + b.get_index(row, col)
			matrix.set_index(row, col, value)
	return matrix


func sigmoid() -> Matrix:
	var matrix = Matrix.new(no_of_rows, no_of_columns)
	# The sigmoid function.
	for row in range(no_of_rows + 1):
		for col in range(no_of_columns + 1):
			var value = 1.0 / (1.0 + exp(-get_index(row, col)))
			matrix.set_index(row, col, value)
	return matrix

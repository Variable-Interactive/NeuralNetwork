class_name Matrix
extends RefCounted
## Used to get access to different matrix methods
##
## Godot does not provide matrix functions so this class exists

var matrix_array: Array[Array]
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
		fill(0)
	_initialized = true


func set_index(row: int, col: int, value: float) -> void:
	if col > no_of_columns:
		printerr("attempting to access column (", col, "), greater than", no_of_columns - 1)
	if row > no_of_rows:
		printerr("attempting to access row (", row, "), greater than", no_of_rows - 1)
	matrix_array[row][col] = value


func get_index(row: int, col: int) -> float:
	if col >= no_of_columns:
		printerr("attempting to access column (", col, "), greater than", no_of_columns - 1)
	if row >= no_of_rows:
		printerr("attempting to access row (", row, "), greater than", no_of_rows - 1)
	return matrix_array[row][col]


func print_pretty():
	print("printing matrix")
	for row in matrix_array:
		print(row)


func to_array() -> Array:
	var array := []
	for row in no_of_rows:
		for column in no_of_columns:
			array.append(get_index(row, column))
	return array


func make_rand_matrix():
	_random.randomize()
	# rows increase top-down so y
	# columns increase from left to right so x
	matrix_array.clear()
	if no_of_rows < 1 or no_of_columns < 1:
		printerr("Can not create, negative values")
		return
	for _y in range(no_of_rows):
		var r = []
		for _x in range(no_of_columns):
			var value = _random.randfn()
			r.append(value)
		matrix_array.append(r)


func fill(value: float):
	matrix_array.clear()
	if no_of_rows < 1 or no_of_columns < 1:
		printerr("Can not create, negative values")
		return
	for _y in range(no_of_rows):
		var r = []
		for _x in range(no_of_columns):
			r.append(value)
		matrix_array.append(r)


# Operators
func dot(b: Matrix) -> Matrix:
	## check if matrix can be multiplied
	if no_of_columns != b.no_of_rows:
		printerr("Incompatible matrices, can not multiply")
		return Matrix.new(0, 0)
	var matrix = Matrix.new(no_of_rows, b.no_of_columns)
	for i in range(no_of_rows):
		for j in range(b.no_of_columns):
			for k in range(no_of_columns):
				var value = matrix.get_index(i, j) + (get_index(i, k) * b.get_index(k, j))
				matrix.set_index(i, j, value)
	return matrix


## multiplies corresponding elements
func multiply_corresponding(b: Matrix, allow_zero := true):
	if Vector2i(no_of_rows, no_of_columns) != Vector2i(b.no_of_rows, b.no_of_columns):
		printerr("Incompatible Matrices, can not multiply corressponding")
		return Matrix.new(0, 0)
	var matrix = Matrix.new(no_of_rows, no_of_columns)
	# this will add two (x, 1) matrices
	for row in range(no_of_rows):
		for col in range(no_of_columns):
			var value = get_index(row, col) * b.get_index(row, col)
			if value == 0 and !allow_zero:
				value = 0.1
			matrix.set_index(row, col, value)
	return matrix


func add(b: Matrix) -> Matrix:
	if Vector2i(no_of_rows, no_of_columns) != Vector2i(b.no_of_rows, b.no_of_columns):
		printerr("Incompatible Matrices, can not add")
		return Matrix.new(0, 0)
	var matrix = Matrix.new(no_of_rows, no_of_columns)
	# this will add two (x, 1) matrices
	for row in range(no_of_rows):
		for col in range(no_of_columns):
			var value = get_index(row, col) + b.get_index(row, col)
			matrix.set_index(row, col, value)
	return matrix


func sigmoid() -> Matrix:
	var matrix = Matrix.new(no_of_rows, no_of_columns)
	# The sigmoid function.
	for row in range(no_of_rows):
		for col in range(no_of_columns):
			var value = 1.0 / (1.0 + exp(-get_index(row, col)))
			matrix.set_index(row, col, value)
	return matrix


func copy() -> Matrix:
	var matrix = Matrix.new(no_of_rows, no_of_columns)
	matrix.matrix_array = matrix_array.duplicate(true)
	return matrix

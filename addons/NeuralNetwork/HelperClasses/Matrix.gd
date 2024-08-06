class_name Matrix
extends RefCounted
## Used to get access to different matrix methods
##
## Godot does not provide matrix functions so this class exists

var no_of_rows: int:  ## making it kinda write protected
	get:
		return _no_of_rows
var no_of_columns: int:  ## making it kinda write protected
	get:
		return _no_of_columns

var _no_of_rows: int
var _no_of_columns: int
var _random := RandomNumberGenerator.new()
var _matrix_array: Array[PackedFloat32Array]


func _init(_rows: int, _columns: int, random := false, generate_fill := true) -> void:
	_no_of_rows = _rows
	_no_of_columns = _columns
	if generate_fill:
		if random:
			make_rand_matrix()
		else:
			fill(0)


## Returns a new unique clone of the matrix.
func clone(transposed := false) -> Matrix:
	var matrix: Matrix
	if transposed:
		matrix = Matrix.new(no_of_columns, no_of_rows)
		for row in no_of_columns:
			for col in no_of_rows:
				matrix.set_index(row, col, get_index(col, row))
	else:
		matrix = Matrix.new(no_of_rows, no_of_columns, false, false)
		matrix._matrix_array = _matrix_array.duplicate(true)
	return matrix


func set_index(row: int, col: int, value: float) -> void:
	if col > no_of_columns:
		printerr("attempting to access column (", col, "), greater than", no_of_columns - 1)
	if row > no_of_rows:
		printerr("attempting to access row (", row, "), greater than", no_of_rows - 1)
	_matrix_array[row][col] = value


func get_index(row: int, col: int) -> float:
	if col >= no_of_columns:
		printerr("attempting to access column (", col, "), greater than", no_of_columns - 1)
	if row >= no_of_rows:
		printerr("attempting to access row (", row, "), greater than", no_of_rows - 1)
	return _matrix_array[row][col]


func print_pretty() -> void:
	print("printing matrix")
	for row: PackedFloat32Array in _matrix_array:
		print(row)


## Returns a normally-distributed pseudo-random matrix, using Box-Muller transform
## with the specified [param mean] and a standard [param deviation].
## This is also called Gaussian distribution.
func make_rand_matrix(mean: float = 0, deviation: float = 1.0) -> void:
	_random.randomize()
	assert(no_of_rows >= 1 or no_of_columns >= 1, "Can not create, 0 or negative size detected")
	# rows increase top-down so y
	# columns increase from left to right so x
	_matrix_array.clear()
	for _y: int in no_of_rows:
		var r: PackedFloat32Array = []
		for _x: int in no_of_columns:
			var value = _random.randfn(mean, deviation)
			r.append(value)
		_matrix_array.append(r)


## Fills a matrix with the given [param value]
func fill(value: float) -> void:
	assert(no_of_rows >= 1 or no_of_columns >= 1, "Can not create, 0 or negative size detected")
	_matrix_array.clear()
	for _y: int in no_of_rows:
		var r: PackedFloat32Array = []
		r.resize(no_of_columns)
		r.fill(value)
		_matrix_array.append(r)


# Operators
## Matrix multiplication [equivalent of numpy.dot()].
func product_matrix(b: Matrix) -> Matrix:
	## check if matrix can be multiplied
	assert(no_of_columns == b.no_of_rows, "Incompatible matrices, can not multiply")
	var matrix := Matrix.new(no_of_rows, b.no_of_columns)
	for i: int in range(no_of_rows):
		for j: int in range(b.no_of_columns):
			for k: int in range(no_of_columns):
				var value = matrix.get_index(i, j) + (get_index(i, k) * b.get_index(k, j))
				matrix.set_index(i, j, value)
	return matrix


## multiplies corresponding elements of two matrices [equivalent of python's (*)]
func multiply_corresponding(b: Matrix) -> Matrix:
	if Vector2i(no_of_rows, no_of_columns) != Vector2i(b.no_of_rows, b.no_of_columns):
		printerr("Incompatible Matrices, can not multiply corressponding")
		return Matrix.new(0, 0)
	var matrix := clone()
	# this will add two (x, 1) matrices
	for row: int in range(no_of_rows):
		for col: int in range(no_of_columns):
			var value := get_index(row, col) * b.get_index(row, col)
			matrix.set_index(row, col, value)
	return matrix


## Scalar Multiplication.
func multiply_scalar(b: float) -> Matrix:
	assert(no_of_rows >= 1 or no_of_columns >= 1, "Can not create, 0 or negative size detected")
	var matrix := clone()
	# this will add two (x, 1) matrices
	for row in range(no_of_rows):
		for col in range(no_of_columns):
			var value = get_index(row, col) * b
			matrix.set_index(row, col, value)
	return matrix


# Addition.
func add(b) -> Matrix:
	if b is Matrix:
		assert(
			Vector2i(no_of_rows, no_of_columns) == Vector2i(b.no_of_rows, b.no_of_columns),
			"Incompatible Matrices, can not add"
		)
	var matrix := clone()
	# this will add two (x, 1) matrices
	for row: int in range(no_of_rows):
		for col: int in range(no_of_columns):
			if b is Matrix:
				matrix.set_index(row, col, get_index(row, col) + b.get_index(row, col))
			else:
				matrix.set_index(row, col, get_index(row, col) + b)
	return matrix


# subtraction (a - self).
func subtract_from(a) -> Matrix:
	if a is Matrix:
		assert(
			Vector2i(no_of_rows, no_of_columns) == Vector2i(a.no_of_rows, a.no_of_columns),
			"Incompatible Matrices, can not add"
		)
	var matrix := clone()
	# this will add two (x, 1) matrices
	for row: int in range(no_of_rows):
		for col: int in range(no_of_columns):
			if a is Matrix:
				matrix.set_index(row, col, a.get_index(row, col) - get_index(row, col))
			else:
				matrix.set_index(row, col, a - get_index(row, col) - a)
	return matrix


## Returns the index of maximum value in matrix
func argmax() -> int:
	var test: Array = []
	for line: PackedFloat32Array in _matrix_array:
		test.append_array(line)
	return test.find(test.max())


## Returns the index of minimum value in matrix
func argmin() -> int:
	var test: Array = []
	for line: PackedFloat32Array in _matrix_array:
		test.append_array(line)
	return test.find(test.min())


## Returns maximum value in matrix
func max_value() -> float:
	var result := 0.0
	for line: PackedFloat32Array in _matrix_array:
		result = maxf(Array(line).max(), result)
	return result


## Returns minimum value in matrix
func min_value() -> float:
	var result := 0.0
	for line: PackedFloat32Array in _matrix_array:
		result = minf(Array(line).min(), result)
	return result


## Returns a new matrix with the sigmoid values of original matrix.
## the sigmoid will work well on numbers above -36 or below 36
func sigmoid() -> Matrix:
	var matrix := clone()
	for row: int in range(no_of_rows):
		for col: int in range(no_of_columns):
			var x = get_index(row, col)
			if x > 36 or x < -36:
				push_warning("Too large value!!!, sigmoid may give incorrect results: ", x)
			var value = 1.0 / (1.0 + exp(- x))
			matrix.set_index(row, col, value)
	return matrix


func sigmoid_prime() -> Matrix:
	var sig_z := sigmoid()
	return sig_z.multiply_corresponding(sig_z.subtract_from(1))


## ReLU (rectified linear unit) activation function
func relu() -> Matrix:
	var matrix := clone()
	# The sigmoid function.
	for row: int in range(no_of_rows):
		for col: int in range(no_of_columns):
			matrix.set_index(row, col, maxf(0, get_index(row, col)))
	return matrix


## softmax activation function
## https://www.pinecone.io/learn/softmax-activation/
func softmax() -> Matrix:
	var matrix := clone()
	var exp_sum = 0
	# The sigmoid function.
	for row: int in range(no_of_rows):
		for col: int in range(no_of_columns):
			exp_sum += exp(get_index(row, col))
	for row: int in range(no_of_rows):
		for col: int in range(no_of_columns):
			matrix.set_index(row, col, exp(get_index(row, col)) / exp_sum)
	return matrix

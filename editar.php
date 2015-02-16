<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>Busqueda</title>
	<script src="js/jquery-1.11.2.min.js"type="text/javascript"></script>
	<link rel='stylesheet' type='text/css'href='TimePicki-master/css/timepicki.css'/>
	<script type='text/javascript'src='TimePicki-master/js/timepicki.js'></script>
	<link href="css/bootstrap.min.css" rel="stylesheet">
</head>
<body>

	<h1>Busqueda</h1>
	<form method="GET" action="resultado_editar.php">

		<label for="dni">Ingrese el DNI :</label>
		<input type="text" name="dni" required maxlength="8">
		<label for="desde">Desde :</label>
		<input type="date" name="desde" required>
		<label for="hasta">Hasta :</label>
		<input type="date" name="hasta" required>
		<input type="submit" value="Buscar" />
	</form>
	
</body>
</html>
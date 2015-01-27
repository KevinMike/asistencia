<?php
	include("scripts/conexion.php");
	//Seleccionar los valores para el select area
	$resultado = mysql_query('select * from area',$enlace);
	if(!$resultado)
	{
		die('No se pudo realizar la consulta : '.mysql_error());
	}
	$opciones = "";
	while ($fila = mysql_fetch_array($resultado)) 
	{
		$opciones .= '<option value="'.$fila['cod_area'].'">';
		$opciones .= $fila['nombre'];
		$opciones .= '</opcion>';
	}
	//Imprimir los valores de la tabla empleados
	$resultado = mysql_query('select * from personal',$enlace);
	if(!$resultado)
	{
		die('No se pudo realizar la consulta : '.mysql_error());
	}
	$opciones2 = "";
	while ($fila = mysql_fetch_array($resultado)) 
	{
		$opciones2 .= '<tr><td>'.$fila['dni'].'</td><td>';
		$opciones2 .= $fila['nombre'].'</td><td>';
		$opciones2 .= $fila['apellido'].'</td><td>';
		$opciones2 .= $fila['fecha_nacimiento'].'</td><td>';
		$opciones2 .= $fila['sexo'].'</td><td>';
		$opciones2 .= $fila['area_cod_area'].'</td><td>';
		$opciones2 .= $fila['cargo'].'</td><td>';
		$opciones2 .= "<a href='#.php?dni={$fila['dni']}'>Editar</a></td><td>";
		$opciones2 .= "<a href='scripts/eliminar_persona.php?dni={$fila['dni']}'>Eliminar</a></td></tr>";
	}
	mysql_close();
?>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>Registrar Empleados</title>
	<link href="css/bootstrap.min.css" rel="stylesheet">
	<link href="css/starter-template.css" rel="stylesheet">
</head>
<body>
	<h1>Ingrese sus datos</h1>
	<form class="form-horizontal" role="form" action="scripts/registro_empleado.php" method="POST">
		<table class="table">
			<tr>
				<td><label for="DNI">Ingrese el DNI</label></td>
				<td><input type="text" name="DNI" required></td>
			</tr>
			<tr>
				<td><label for="nombre">Nombre</label></td>
				<td><input type="text" name="nombre" required></td>
			</tr>
			<tr>
				<td><label for="apellido">Apellidos</label></td>
				<td><input type="text" name="apellido" required></td>
			</tr>
			<tr>
				<td><label for="fecha_nacimiento">Fecha de Nacimiento</label></td>
				<td><input type="date" name="fecha_nacimiento" required></td>
			</tr>
			<tr>
				<td><label for="sexo">Sexo</label></td>
				<td><select name="sexo" required>
					<option value="1">Hombre</option>
					<option value="0">Mujer</option>
				</select></td>
			</tr>
			<tr>
				<td><label for="area">Área</label></td>
				<td><select  name="area" required>
					<?php echo $opciones; ?>
				</select></td>
			</tr>
			<tr>
				<td><label for="password">Contraseña de ingreso</label></td>
				<td><input type="password" name="password" required></td>
			</tr>
			<tr>
				<td><label for="password2">Vuelva a escribir su contraseña</label></td>
				<td><input type="password" name="password2" required></td>
			</tr>
			<tr>
				<td><label for="cargo">Cargo</label></td>
				<td><input type="text" name="cargo"required></td>
			</tr>
		</table>
		<input type="submit" class="btn btn-success" value="Registrar">
		<input class="btn btn-primary" type="reset">
	</form>
	<h2>Personal Registrados</h2>
	<table class="table table-striped">
		<tr >
			<th>DNI</th>
			<th>Nombres</th>
			<th>Apellidos</th>
			<th>Fecha de Nacimiento</th>
			<th>Sexo</th>
			<th>Area</th>
			<th>Cargo</th>
			<th>Eliminar Registro</th>
			<th>Actualizar datos</th>
		</tr>
			<?php echo $opciones2; ?>
	</table>
</body>
</html>

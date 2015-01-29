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
	<form class="form-horizontal" role="form" action="scripts/registro_empleado.php" method="POST" enctype="multipart/form-data">

				<div class="form-group">

			<label for="DNI">Ingrese el DNI</label>
				
				<input type="text" name="DNI" required maxlength="8">
				
				</div>

			<table class="table"> 
			<tr>
				<td><label for="nombre">Nombre</label></td>
				<td><input type="text" name="nombre" required maxlength="35"></td>
			</tr>
			<tr>
				<td><label for="apellido">Apellidos</label></td>
				<td><input type="text" name="apellido" required maxlength="35"></td>
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
				<td><label for="horario">Horario</label></td>
				<td><select name="horario">
					<option value=""></option>
				</select>		<a href="">Agregar Nuevo Horario</a></td>
				<div class="checkbox">
					<label><input type="checkbox" name="Sunday" value="1"> Domingo<br></label>
					<label><input type="checkbox" name="Monday" value="1r" checked> Lunes<br></label>
					<label><input type="checkbox" name="Tuesday" value="1"> Martes<br></label>
					<label><input type="checkbox" name="Wednesday" value="1"> Miercoles<br></label>
					<label><input type="checkbox" name="Thursday" value="1" checked> Jueves<br></label>
					<label><input type="checkbox" name="Friday" value="1"> Viernes<br></label>
					<label><input type="checkbox" name="Saturday" value="1"> Sábado<br></label>
				</div>
			</tr>
			<tr>
				<td><label for="password">Contraseña de ingreso</label></td>
				<td><input type="password" name="password" required maxlength="15"></td>
			</tr>
			<!--<tr>
				<td><label for="password2">Vuelva a escribir su contraseña</label></td>
				<td><input type="password" name="password2" required maxlength="15"></td>
			</tr>-->
			<tr>
				<td><label for="cargo">Cargo</label></td>
				<td><input type="text" name="cargo"required maxlength="15"></td>
			</tr>
			<tr>
				 <td><label for="userfile">Foto</label></td>   
				 <td><input name="userfile" type="file"></td>
			</tr>
		</table>
		<input type="submit" class="btn btn-success" value="Registrar">
		<input class="btn btn-primary" type="reset">
	</form>
	ejemlpoo
	<form role="form">
  <div class="form-group">
    <label for="ejemplo_email_1">Email</label>
    <input type="email" class="form-control" id="ejemplo_email_1"
           placeholder="Introduce tu email">
  </div>
  <div class="form-group">
    <label for="ejemplo_password_1">Contraseña</label>
    <input type="password" class="form-control" id="ejemplo_password_1" 
           placeholder="Contraseña">
  </div>
  <div class="form-group">
    <label for="ejemplo_archivo_1">Adjuntar un archivo</label>
    <input type="file" id="ejemplo_archivo_1">
    <p class="help-block">Ejemplo de texto de ayuda.</p>
  </div>
  <div class="checkbox">
    <label>
      <input type="checkbox"> Activa esta casilla
    </label>
  </div>
  <button type="submit" class="btn btn-default">Enviar</button>
</form>
	ejemplo

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


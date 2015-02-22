<?php
	session_start();
	if ($_SESSION['login'] != true) {
	 	header("Location:index.php");
	 } 
	include("scripts/conexion.php");
	//Seleccionar los valores para el select area
	$resultado = mysql_query('select * from area',$enlace) or die("Error : ".mysql_error());
	if(!$resultado)
	{
		die('No se pudo realizar la consulta : '.mysql_error()) ;
	}
	$opciones = "";
	while ($fila = mysql_fetch_array($resultado)) 
	{
		$opciones .= '<option value="'.$fila['cod_area'].'">';
		$opciones .= $fila['nombre'];
		$opciones .= '</opcion>';
	}
	//Seleccionar los valores de los horarios
	$resultado = mysql_query('select * from V_horarios',$enlace) or die("Error : ".mysql_error());
	if(!$resultado)
	{
		die('No se pudo realizar la consulta : '.mysql_error());
	}
	$opciones1 = "";
	while ($fila = mysql_fetch_array($resultado)) 
	{
		$opciones1 .= '<option value="'.$fila['cod_horario'].'">';
		$opciones1 .= $fila['Horario'];
		$opciones1 .= '</opcion>';
	}
	//Imprimir los valores de la tabla empleados
	$resultado = mysql_query('select * from V_empleados',$enlace) or die("Error : ".mysql_error());
	if(!$resultado)
	{
		die('No se pudo realizar la consulta : '.mysql_error());
	}
	$opciones2 = "";
	while ($fila = mysql_fetch_array($resultado)) 
	{
		$opciones2 .= "<tr><td><img src='";
		if ($fila['tipo'] == '')  
		{
			$opciones2 .= "img/sin_avatar.jpg";	
		}
		else
		{
			$opciones2 .= 'scripts/visualizar_imagen.php?dni='.$fila['dni'];
		}
		$opciones2 .= "' width = 80px ><td>".$fila['dni']."</td><td>";
		$opciones2 .= $fila['nombre']."</td><td>";
		$opciones2 .= $fila['apellido']."</td><td>";
		$opciones2 .= $fila['fecha_nacimiento']."</td><td>";
		$opciones2 .= $fila['sexo']."</td><td>";
		$opciones2 .= $fila['area']."</td><td>";
		$opciones2 .= $fila['cargo']."</td><td>";
		$opciones2 .= $fila['password']."</td><td>";
		$opciones2 .= $fila['Horario']."</td><td>";
		$opciones2 .= $fila['dias']."</td><td>";
		$opciones2 .= "<a href='empleados.php?dni={$fila['dni']}'>Editar</a></td><td>";
		$opciones2 .= "<a href='scripts/eliminar_persona.php?dni={$fila['dni']}'>Eliminar</a></td></tr>";
	}
	//Edicion de los Empleados
	$aviso = "";
	if (!empty($_GET['dni'])) 
	{
	// traemos la noticia
		$aviso= "<B><h4>EDITANTO AL EMPLEADO DE DNI <b>".$_GET['dni']."</h4>";
		$query = "select * from V_edicion_empleados where dni = '{$_GET['dni']}' Limit 1";
		$respuesta = mysql_query($query) or die("Error : ".mysql_error());
		while ($fila = mysql_fetch_array($respuesta)) 
		{
			echo "<script type='text/javascript'>var dni =  ".$fila['dni'].";</script>";
			echo "<script type='text/javascript'>var nombre = '".$fila['nombre']."';</script>";
			echo "<script type='text/javascript'>var apellido = '".$fila['apellido']."';</script>";
			echo "<script type='text/javascript'>var fecha_nacimiento = '".$fila['fecha_nacimiento']."';</script>";
			echo "<script type='text/javascript'>var sexo = '".$fila['sexo']."';</script>";
			echo "<script type='text/javascript'>var area =  ".$fila['cod_area'].";</script>";
			echo "<script type='text/javascript'>var cargo = '".$fila['cargo']."';</script>";
			echo "<script type='text/javascript'>var Horario = '".$fila['Horario']."';</script>";
			echo "<script type='text/javascript'>var Sunday = '".$fila['Sunday']."';</script>";
			echo "<script type='text/javascript'>var Monday =  ".$fila['Monday'].";</script>";
			echo "<script type='text/javascript'>var Tuesday = '".$fila['Tuesday']."';</script>";
			echo "<script type='text/javascript'>var Wednesday = '".$fila['Wednesday']."';</script>";
			echo "<script type='text/javascript'>var Thursday = '".$fila['Thursday']."';</script>";
			echo "<script type='text/javascript'>var Friday =  ".$fila['Friday'].";</script>";
			echo "<script type='text/javascript'>var Saturday = '".$fila['Saturday']."';</script>";
			//echo "<script type='text/javascript'>$(document).ready(function(){$('#DNI').val(dni);$('#nombre').val(nombre);$('#apellido').val(apellido);$('#fecha_nacimiento').val(fecha_nacimiento);$('#sexo').val(sexo);$('#area').val(area);$('#cargo').val(cargo);$('#horario').val(Horario);});</script>"
		}
	}
	else
	{
		echo "<script type='text/javascript'>var dni = '';</script>";
		echo "<script type='text/javascript'>var nombre = '';</script>";
		echo "<script type='text/javascript'>var apellido = '';</script>";
		echo "<script type='text/javascript'>var fecha_nacimiento = '';</script>";
		echo "<script type='text/javascript'>var sexo = '';</script>";
		echo "<script type='text/javascript'>var area =  '';</script>";
		echo "<script type='text/javascript'>var cargo = '';</script>";
		echo "<script type='text/javascript'>var Horario = '';</script>";
	}
	mysql_close();
?>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>Registrar Empleados</title>
	<link href="css/bootstrap.min.css" rel="stylesheet">
	<link href="css/panel.css" rel="stylesheet">
	<script src="js/jquery-1.11.2.min.js"type="text/javascript"></script>
</head>
<body>
	<header>
		<figure>
			<img src="img/inei.png" width="120px" alt="">
		</figure>
		<div class="contenedor">
			<div class="titulo">
				<h1>SISTEMA DE ASISTENCIA</h1>
			</div>
			<nav>
				<li><a href="index.php">Inicio</a></li>
				<li><a href="editar.php">Edicion y Reporte de Registros</a></li>
				<li><a href="empleados.php">Gestionar Personal</a></li>
				<li><a href="scripts/cerrar_sesion.php">Cerrar Sesion</a></li>
			</nav>
		</div>
	</header>
	<section>
		<h1>Registro del Personal</h1>
		<?php echo $aviso;?>
			<script type='text/javascript'>
				$(document).ready(function()
				{
					$('#DNI').val(dni);
					$('#nombre').val(nombre);
					$('#apellido').val(apellido);
					$('#fecha_nacimiento').val(fecha_nacimiento);
					$('#sexo').val(sexo);
					$('#area').val(area);
					$('#cargo').val(cargo);
					$('#horario').val(Horario);
				});
			</script>
		<form class="form-horizontal" role="form" action="scripts/registro_empleado.php" method="POST" enctype="multipart/form-data">
				<table class="table"> 
				<tr>	
					<div class="form-group">
						<td><label for="DNI">Ingrese el DNI</label></td>
						<td><input class="form-control" id = "DNI" type="text" name="DNI" required maxlength="8"></td>
					</div>
				</tr>
				<tr>
					<td><label for="nombre">Nombre</label></td>
					<td><input class="form-control" id = "nombre" type="text" name="nombre" required maxlength="35"></td>
				</tr>
				<tr>
					<td><label for="apellido">Apellidos</label></td>
					<td><input class="form-control" id = "apellido" type="text" name="apellido" required maxlength="35"></td>
				</tr>
				<tr>
					<td><label for="fecha_nacimiento">Fecha de Nacimiento</label></td>
					<td><input class="form-control" id = "fecha_nacimiento" type="date" name="fecha_nacimiento" required></td>
				</tr>
				<tr>
					<td><label for="sexo">Sexo</label></td>
					<td><select class="form-control" id = "sexo" name="sexo" required>
						<option value="1">Hombre</option>
						<option value="0">Mujer</option>
					</select></td>
				</tr>
				<tr>
					<td><label for="area">Área</label></td>
					<td><select class="form-control" id = "area" name="area" required>
						<?php echo $opciones; ?>
					</select></td>
				</tr>
				<tr>
					<td><label for="horario">Horario</label></td>
					<td><select class="form-control" id = "horario" name="horario">
						<?php echo $opciones1;?>
					</select>		<a href="horario.php">Agregar Nuevo Horario</a></td>
				</tr>
				<tr>
					<td><label for="dias">Dias Laborables</label></td>
					<td><div  id = "dias" class="checkbox" name="dias">
						<label><input type="checkbox" id="Sunday" name="Sunday" value="1" falsevalue="0"> Domingo<br></label> <br>
						<label><input type="checkbox" id="Monday" name="Monday" value="1" falsevalue="0"> Lunes<br></label> <br>
						<label><input type="checkbox" id="Tuesday" name="Tuesday" value="1" falsevalue="0"> Martes<br></label> <br>
						<label><input type="checkbox" id="Wednesday" name="Wednesday" value="1" falsevalue="0"> Miercoles<br></label> <br>
						<label><input type="checkbox" id="Thursday" name="Thursday" value="1" falsevalue="0"> Jueves<br></label> <br>
						<label><input type="checkbox" id="Friday" name="Friday" value="1" falsevalue="0"> Viernes<br></label> <br>
						<label><input type="checkbox" id="Saturday" name="Saturday" value="1" falsevalue="0"> Sábado<br></label> 
					</div>
					<!--<br><input class="form-control" type="reset" class="btn btn-default"></td>-->
				</tr>
				<tr>
					<td><label for="password">Contraseña de ingreso</label></td>
					<td><input class="form-control" id="password"type="password" name="password" required maxlength="15"><p>(Evitar el uso de ñ y tildes en la contraseña)</p></td>
				</tr>
				<!--<tr>
					<td><label for="password2">Vuelva a escribir su contraseña</label></td>
					<td><input type="password" name="password2" required maxlength="15"></td>
				</tr>-->
				<tr>
					<td><label for="cargo">Cargo</label></td>
					<td><input class="form-control" id="cargo" type="text" name="cargo"required maxlength="15"></td>
				</tr>
				<tr>
					 <td><label for="userfile">Foto</label></td>   
					 <td><input name="userfile" type="file"></td>
				</tr>
			</table>
			<input type="submit" class="btn btn-success" value="Registrar">
			<input class="btn btn-primary" type="reset">
		</form>

		<script type="text/javascript">
			$(document).ready(function(){
		                                
		        var consulta;
		                                                                          
		         //hacemos focus al campo de búsqueda
		        //$("#busqueda").focus();
		                                                                                                    
		        //comprobamos si se pulsa una tecla
		        $("#busqueda").keyup(function(e){
	                  
		              //obtenemos el texto introducido en el campo de búsqueda
		              consulta = $("#busqueda").val();
		                                                                           
		              //hace la búsqueda
		                                                                                  
		              $.ajax({
		                    type: "POST",
		                    url: "scripts/buscar.php",
		                    data: "buscardni="+consulta,
		                    dataType: "html",
		                    beforeSend: function(){
		                          //imagen de carga
		                          $("#resultado").html("<p align='center'><img src='ajax-loader.gif' /></p>");
		                    },
		                    error: function(){
		                          alert("error petición ajax");
		                    },
		                    success: function(data){                                                    
		                          $("#resultado").empty();
		                          $("#resultado").append(data);
		                                                             
		                    }
		              });
		                                                                                  
		        });
		                                                                   
		});
		</script>
		<h2>Busqueda del Personal por DNI</h2>
		<form class="form">
			<label for="buscadni">Ingrese el DNI : </label>
			<input type="text" id="busqueda" name="buscadni" maxlength="8"/>
		</form>
	    <table class="table table-striped" id="resultado"></table>


		<h2>Personal Registrado</h2>
		<table class="table table-striped">
			<tr >
				<th>Foto</th>
				<th>DNI</th>
				<th>Nombres</th>
				<th>Apellidos</th>
				<th>Fecha de Nacimiento</th>
				<th>Sexo</th>
				<th>Area</th>
				<th>Cargo</th>
				<th>Pass</th>
				<th>Horario</th>
				<th>Dias Laborables</th>
				<th>Eliminar</th>
				<th>Actualizar</th>
			</tr>
				<?php echo $opciones2; ?>
		</table>
	</section>
</body>
</html>


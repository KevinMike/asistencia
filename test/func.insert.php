<html>
<head>
<title>func.insert.php</title>
<meta http-equiv='content-type' content='text/html; charset=UTF-8'/>
</head>
<body>

<form action='func.insert.php' method='post'>
	<div><input type='text' name='title'/> Título</div>
	<div><input type='text' name='link'/> Enlace</div>
	<div><input type='text' name='description'/> Descripción</div>
	<div><input type='text' name='author'/> Autor</div>
	<div><input type='submit' name='insert' value='Insertar registro'/></div>
</form>

<?php 
if($_POST[insert]){
	
	$date=date(c); // Obtener fecha de registro
	
	include("config.php");
	mysql_select_db("$database", $con);
	mysql_query("INSERT INTO items SET title='$_POST[title]', link='$_POST[link]', description='$_POST[description]', author='$_POST[author]', regdated='$date', indexer='$_POST[title] $_POST[description] $_POST[author]'", $con);

	// Actualizar la página de inserción de registros
	echo "<script language='javascript'>window.location.href='func.insert.php';</script>";
	
}
?>

</body>
</html>
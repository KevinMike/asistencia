<html>
<head>
<title>func.edit.php</title>
<meta http-equiv='content-type' content='text/html; charset=UTF-8'/>
</head>
<body>

<?php 
include("config.php");
mysql_select_db("$database", $con);
$results = mysql_query("SELECT * FROM items",$con);
while($row = mysql_fetch_assoc($results)){
	
	echo "
	<div style='margin-top: 10px; margin-bottom: 10px;'>
	<form action='func.edit.php' method='post'>
		<input type='hidden' name='id' value='$row[id]'/>
		<input type='text' name='title' value='$row[title]'/>
		<input type='text' name='link' value='$row[link]'/>
		<input type='text' name='author' value='$row[author]'/>
		<textarea name='description'>$row[description]</textarea>
		<input type='submit' name='edit' value='guardar cambios'/>
		<input type='submit' name='delete' value='eliminar'/>
	</form>
	</div>
	";
		
}
?>


<?php 
if($_POST[edit]){

	$date=date(c); // Obtener fecha de registro

	include("config.php");
	mysql_select_db("$database", $con);
	mysql_query("UPDATE items SET title='$_POST[title]', link='$_POST[link]', author='$_POST[author]', description='$_POST[description]', updated='$date', indexer='$_POST[title] $_POST[author] $_POST[description]' WHERE id='$_POST[id]'",$con);
	
	// Actualizar la página de edición de registros
	echo "<script language='javascript'>window.location.href='func.edit.php';</script>";

}
?>


<?php 
if($_POST[delete]){

	include("config.php");
	mysql_select_db("$database", $con);
	mysql_query("DELETE FROM items WHERE id='$_POST[id]'",$con);
	
	// Actualizar la página de edición de registros
	echo "<script language='javascript'>window.location.href='func.edit.php';</script>";

}
?>

</body>
</html>
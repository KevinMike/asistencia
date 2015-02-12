<?
// datos de configuracion
$ip = 'localhost';
$usuario = 'usuario';
$password = 'password';
$db_name = 'baseDeDatos';
// conectamos con la db
$conn = mysql_pconnect($ip,$usuario,$password) or die();
// seleccionamos la base de datos
$huboerror = mysql_select_db($db_name,$conn) or die();
// si se envia el formulario de edicion
if ( !empty($_POST['submit']) ) {
$query = "UPDATE `noticias` set titulo = '{$_POST['titulo']}', set cuerpo = '{$_POST['cuerpo']}', estado = '{$_POST['estado']}' WHERE idNoticia = {$_POST['idNoticia']} LIMIT 1";
$response = mysql_query($query, $conn);
}
// si tenemos id de noticia
if ( !empty($_GET['idNoticia']) ) {
// traemos la noticia
$query = "SELECT idNoticia,titulo,cuerpo,estado FROM `noticias` WHERE idNoticia = {$_GET['idNoticia']} limit 1";
$response = mysql_query($query, $conn);
$noticia = mysql_fetch_assoc($response);
}
?>
<html>
<head>
<title>Formulario de Edición de Noticias</title>
</head>
<body>
<h1>Agregar Nueva Noticia</h1>
<form action="editar-noticias.php" method="post">
<label for="titulo">Titulo</label><br />
<input id="titulo" name="titulo" value= <? echo $noticia['titulo']; ?> type="text" /><br /><br />
<label for="cuerpo">Cuerpo</label><br />
<textarea id="cuerpo" name="cuerpo" rows="5" cols="50"><? echo $noticia['cuerpo']; ?></textarea><br /><br />
<label for="estado">Estado</label>
<select id="estado" name="estado">
<option value="publicado" <? if ( $noticia['estado'] == 'publicado' ) echo 'selected="selected"'; ?>>Publicado</option>
<option value="borrado" <? if ( $noticia['estado'] == 'borrado' ) echo 'selected="selected"'; ?>>Borrado</option>
</select><br /><br />
<button type="submit" name="submit" value="1">Editar Noticia</button>
<input name="idNoticia" value="<? echo $noticia['idNoticia']; ?>" type="hidden" />
</form>
</body>
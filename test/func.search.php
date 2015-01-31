<html>
<head>
<title>func.search.php</title>
<meta http-equiv='content-type' content='text/html; charset=UTF-8'/>
</head>
<body>

<form action='func.search.php' method='post'>
	<input type='text' name='query'/>
	<input type='submit' name='search' value='Buscar'/>
</form>

<?php 
if($_POST[search]){
	
	include("config.php");
	mysql_select_db("$database", $con);
	$results = mysql_query("SELECT * FROM items WHERE indexer LIKE '%$_POST[query]%'",$con);
	while($row = mysql_fetch_assoc($results)){
	
		echo "
		<div style='margin-top: 10px; margin-bottom: 10px;'>
			$row[id] .- $row[title] / $row[author] .- $row[description]. Disponible en: <a href='$row[link]' title='$row[title]' target='_blank'>$row[link]</a>
		</div>
		";

	}
	
}
?>

</body>
</html>
<?php
require("./dbconfig.php");
require("./keys/keys.php");
$param_email = $param_password = "";
// Write SQL query to retrieve hashPass from table
$sql = "SELECT * FROM journals WHERE userID = :userID";
if ($stmt = $pdo->prepare($sql)) {
    // Bind variables to the prepared statement as parameters
    $userID = trim($_POST["userID"]);
    $stmt->bindParam(":userID", $userID, PDO::PARAM_INT);
    // Attempt to execute the prepared statement
    if ($stmt->execute()) {
        // Set result to be associated with column name
        $stmt->setFetchMode(PDO::FETCH_ASSOC);
        // Fetch encrypted entry from result
        $all_entries = array();
        
        while ($row = $stmt->fetch()) {
            $encrypted_entry = $row['entry'];
            $encrypted_topics = $row['topics'];
            $mcrypt = mcrypt_module_open('rijndael-256', '', 'cbc', '');//Opens the module
            mcrypt_generic_init($mcrypt, $key, $iv);
            // Open mcrypt module and buffer for decryption
            // Trim invisible padding characters from the decrypted entry
            $decrypted_entry = trim(mdecrypt_generic($mcrypt, base64_decode($encrypted_entry)), "\0\4");
            // Close mcrypt module and buffer
            mcrypt_generic_deinit($mcrypt);
            mcrypt_module_close($mcrypt);
            $mcrypt = mcrypt_module_open('rijndael-256', '', 'cbc', '');//Opens the module

            mcrypt_generic_init($mcrypt, $key, $iv);
            // Open mcrypt module and buffer for decryption
            // Trim invisible padding characters from the decrypted entry
            $decrypted_topics = trim(mdecrypt_generic($mcrypt, base64_decode($encrypted_topics)), "\0\4");
            // Close mcrypt module and buffer
            mcrypt_generic_deinit($mcrypt);
            mcrypt_module_close($mcrypt);

            $jourID = $row['jourID'];
            $userID = $row['userID'];
            $created = $row['created'];
            $hidden = $row['hidden'];
            $sentScore = $row['sentScore'];
            $rating = $row['rating'];
            $lastEdited = $row['lastEdited'];
            // $topics = $row['topics'];
            $sentiment = $row['sentiment'];
            $positive = $row['positive'];
            $negative = $row['negative'];
            $mixed = $row['mixed'];
            $neutral = $row['neutral'];
            array_push($all_entries, array("jourID" => $jourID,
                                           "userID" => $userID,
                                           "entry" => $decrypted_entry,
                                           "created" => $created,
                                           "hidden" => $hidden,
                                           "sentiment" => $sentiment,
                                           "sentScore" => $sentScore,
                                           "rating" => $hidden,
                                           "lastEdited" => $lastEdited,
                                           "topics" => $decrypted_topics,
                                           "positive" => $positive,
                                           "negative" => $negative,
                                           "mixed" => $mixed,
                                           "neutral" => $neutral)); 
        }
        $json = json_encode($all_entries, JSON_PRETTY_PRINT);
        echo $json;
        //var_dump($all_entries);
        
    } else {
        echo "Oops! Something went wrong. Please try again later.";
    }

    // Close statement
    unset($stmt);
}

// Close connection with database
unset($pdo);
?>
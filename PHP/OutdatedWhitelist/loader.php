<?php
        
        class Encryption
        {


            /**
             * @link http://php.net/manual/en/function.openssl-get-cipher-methods.php Available methods.
             * @var string Cipher method. Recommended AES-128-CBC, AES-192-CBC, AES-256-CBC
             */
            protected $encryptMethod = 'aes-256-cbc';


            /**
             * Decrypt string.
             * 
             * @link https://stackoverflow.com/questions/41222162/encrypt-in-php-openssl-and-decrypt-in-javascript-cryptojs Reference.
             * @param string $encryptedString The encrypted string that is base64 encode.
             * @param string $key The key.
             * @return mixed Return original string value. Return null for failure get salt, iv.
             */
            public function decrypt($encryptedString, $key)
            {
                $json = json_decode(base64_decode($encryptedString), true);

                try {
                    $salt = hex2bin($json["salt"]);
                    $iv = hex2bin($json["iv"]);
                } catch (Exception $e) {
                    return null;
                }

                $cipherText = base64_decode($json['ciphertext']);

                $iterations = intval(abs((int) $json['iterations']));
                if ($iterations <= 0) {
                    $iterations = 999;
                }
                $hashKey = hash_pbkdf2('sha512', $key, $salt, $iterations, ($this->encryptMethodLength() / 4));
                unset($iterations, $json, $salt);

                $decrypted= openssl_decrypt($cipherText , $this->encryptMethod, hex2bin($hashKey), OPENSSL_RAW_DATA, $iv);
                unset($cipherText, $hashKey, $iv);

                return $decrypted;
            }// decrypt


            /**
             * Encrypt string.
             * 
             * @link https://stackoverflow.com/questions/41222162/encrypt-in-php-openssl-and-decrypt-in-javascript-cryptojs Reference.
             * @param string $string The original string to be encrypt.
             * @param string $key The key.
             * @return string Return encrypted string.
             */
            public function encrypt($string, $key)
            {
                $ivLength = openssl_cipher_iv_length($this->encryptMethod);
                $iv = openssl_random_pseudo_bytes($ivLength);
        
                $salt = openssl_random_pseudo_bytes(256);
                $iterations = 999;
                $hashKey = hash_pbkdf2('sha512', $key, $salt, $iterations, ($this->encryptMethodLength() / 4));

                $encryptedString = openssl_encrypt($string, $this->encryptMethod, hex2bin($hashKey), OPENSSL_RAW_DATA, $iv);

                $encryptedString = base64_encode($encryptedString);
                unset($hashKey);

                $output = ['ciphertext' => $encryptedString, 'iv' => bin2hex($iv), 'salt' => bin2hex($salt), 'iterations' => $iterations];
                unset($encryptedString, $iterations, $iv, $ivLength, $salt);

                return base64_encode(json_encode($output));
            }// encrypt


            /**
             * Get encrypt method length number (128, 192, 256).
             * 
             * @return integer.
             */
            protected function encryptMethodLength()
            {
                $number = (int) filter_var($this->encryptMethod, FILTER_SANITIZE_NUMBER_INT);

                return (int) abs(intval($number));
            }// encryptMethodLength


            /**
             * Set encryption method.
             * 
             * @link http://php.net/manual/en/function.openssl-get-cipher-methods.php Available methods.
             * @param string $cipherMethod
             */
            public function setCipherMethod($cipherMethod)
            {
                $this->encryptMethod = $cipherMethod;
            }// setCipherMethod


        }

        function find_one($projection) {
            $ch = curl_init();

            $data = json_encode([
                "collection" => "hwids",
                "database" => "test",
                "dataSource" => "KeysHwids",
                "filter" => $projection
            ]);

            curl_setopt($ch, CURLOPT_URL, 'https://data.mongodb-api.com/app/data-uumun/endpoint/data/beta/action/findOne');
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
            curl_setopt($ch, CURLOPT_POST, 1);
            curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
            
            $headers = array();
            $headers[] = 'Content-Type: application/json';
            $headers[] = 'Access-Control-Request-Headers: *';
            $headers[] = 'Api-Key: 5tnCPRdRw0tl7KERuWZPx6R2YnE3cAaUqfZ38VlrJWSTDgj7da0ZtIe4BKi4MxEF';
            curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
            
            $result = curl_exec($ch);
            if (curl_errno($ch)) {
                echo 'Error:' . curl_error($ch);
            }
            curl_close($ch);  
            return $result;
        };

        // Lets add our variables
        $ENCRYPTION = new Encryption();
        $SERVER_KEY = "x9PqLvx02hrZbLqVh5o07mf3";
        $HWID = "NO HWID!";

        if (isset($_GET['zx0'])) {
            $GET_DATA = $_GET['zx0'];
            $GET_DATA = $ENCRYPTION->decrypt($GET_DATA, $SERVER_KEY);
            $GET_DATA = explode("_", $GET_DATA);
            $KEY = $GET_DATA[0];
            $UID = $GET_DATA[1];
        }

        // Prehand, let's use fingerprint to retrieve the fingerprint HWID
        $HEADERS = getallheaders();
        
        if (isset($HEADERS["SW-Fingerprint"])) {
            $HWID = $HEADERS["SW-Fingerprint"];
        } else if (isset($HEADERS["Sw-Fingerprint"])) {
            $HWID = $HEADERS["Sw-Fingerprint"];
        } else if (isset($HEADERS["Syn-Fingerprint"])) {
            $HWID = $HEADERS["Syn-Fingerprint"];
        } else if (isset($HEADERS["Fingerprint"])) {
            $HWID = $HEADERS["Fingerprint"];
        } else if (isset($HEADERS["fingerprint"])) {
            $HWID = $HEADERS["fingerprint"];
        } else if (isset($HEADERS["Krnl-Fingerprint"])) {
            $HWID = $HEADERS["Krnl-Fingerprint"];
        };

        // Lets start by checking if their HWID even exists in the database (we can use my custom http mongo api)
        $mongo_result = find_one([
            "HWID" => $HWID
        ]); // Search query goes in the square brackets (we will search for hwid)

        // Lets now see if the result is valid
        $mongo_result = json_decode($mongo_result, true); // We have to decode because it returns in json format
        if ($mongo_result["document"] || $mongo_result["document"] != "NULL") { // We search for the document and if there is one, we check if the document is equal to NULL since this is what it returns when there is no document in existance in the database
            $mongo_result = $mongo_result['document']; // Lets redirect the result to the document for ease.
            $data_key = $mongo_result["Key"];
            $data_hwid = $mongo_result["HWID"];
            $data_uid = $mongo_result["UserId"]; // Lets get all the other info from the document

            $data_uid = substr($data_uid, 1, -3);
            if ( isset($UID) && isset($KEY) && stripos($UID, $data_uid) !== false && $KEY == $data_key ) { // Compare HWID and database result
                if ( isset($HEADERS["Game"]) or isset($HEADERS["game"]) ) {
                    if (isset($HEADERS["SW-Fingerprint"]) or isset($HEADERS["Sw-Fingerprint"])) {
                        readfile("/storage/ssd4/391/18505391/public_html/scripts/_" . $HEADERS["game"] . ".lua");
                    } else {
                        readfile("/storage/ssd4/391/18505391/public_html/scripts/_" . $HEADERS["Game"] . ".lua");
                    }
                } else {
                    echo("Invalid game.");
                }
            }
        }
    ?>
<?php   
        $HWID = "Your exploit is not supported, dm Enxquity or Vez.";

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

        echo($HWID)
?>
<?php

$curl = curl_init();
          
curl_setopt_array($curl, array(
  CURLOPT_URL => "_URL",
  CURLOPT_RETURNTRANSFER => true,
  CURLOPT_ENCODING => "",
  CURLOPT_MAXREDIRS => 5,
  CURLOPT_TIMEOUT => 10,
  CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
  CURLOPT_CUSTOMREQUEST => "GET",
  CURLOPT_POSTFIELDS => "",
  CURLOPT_HTTPHEADER => array(
    "Authorization: Basic 1_TOKEN",
    "cache-control: no-cache",
    "content-type: application/json"
  ),
));
          
$response = curl_exec($curl);
$err = curl_error($curl);
          
curl_close($curl);

if ($err) {
  echo "cURL Error #:" . $err;
} else {

  $decodedJson = json_decode($response);

$slotheight = 0;
$slotmissed = 0;
$slotminted = 0;
foreach($decodedJson->assignedSlots as $slots){

 $curl = curl_init();
          
curl_setopt_array($curl, array(
  CURLOPT_URL => "https://cardano-mainnet.blockfrost.io/api/v0/blocks/slot/" . $slots->slot,
  CURLOPT_RETURNTRANSFER => true,
  CURLOPT_ENCODING => "",
  CURLOPT_MAXREDIRS => 5,
  CURLOPT_TIMEOUT => 10,
  CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
  CURLOPT_CUSTOMREQUEST => "GET",
  CURLOPT_POSTFIELDS => "",
  CURLOPT_HTTPHEADER => array(
    "project_id: 2_TOKEN"
  ),
));
          
$response = curl_exec($curl);
$err = curl_error($curl);
          
curl_close($curl);
 
 if ($err) {
  echo "cURL Error #:" . $err;
} else {

  $decodedJsonFor = json_decode($response);
  
$date = date('c');


if(($decodedJsonFor->slot_leader == null && $slots->at < $date) || ($decodedJsonFor->slot_leader != null && $decodedJsonFor->slot_leader != "pool1mchqp2fr7mwsz6jrpplxpr0ekmwafev8arl57wwxfck5x0dwv60")){
    $slotmissed++;
} elseif($decodedJsonFor->status_code == "404"){
    $slotheight++;
} else {
    $slotminted++;
}

}
 
}
echo "<center><b>Blocks minted: <font style='color:green'>{$slotminted}</font> | Blocks missed: <font style='color:red'>{$slotmissed}</font> | Slots's height coming: <font style='color:orange'>{$slotheight}</font></b></center>";
}

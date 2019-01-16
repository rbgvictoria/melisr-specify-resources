<?php

$host = '10.15.15.121';
$db = 'specify_development';

$triggers = array(
    'attachment_before_insert.sql',
    'collectionobject_before_insert.sql',
    'collectionobject_before_update.sql',
    'collectionobject_after_update.sql',
    'collectionobject_before_delete.sql',
    'determination_after_update.sql',
    'exchangein_before_insert.sql',
    'genusstorage_after_insert.sql',
    'genusstorage_after_update.sql',
    //'geocoorddetail_before_insert.sql',
    'gift_before_insert.sql',
    'loan_before_insert.sql',
    'loan_before_update.sql',
    //'locality_before_insert.sql',
    //'locality_after_insert.sql',
    //'locality_before_update.sql',
    'preparation_before_insert.sql',
    'preparation_before_update.sql',
    'shipment_before_insert.sql',
    'taxon_before_insert.sql',
    'taxon_before_update.sql'
);

foreach ($triggers as $trigger) {
    $command = "mysql -h $host -u admin -padmpwd $db < $trigger";
    `$command`;
}
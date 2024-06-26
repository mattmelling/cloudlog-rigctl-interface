<?php
/**
 * @brief        Configuration for the Cloudlog rigctld Interface
 * @date         2018-12-17
 * @author       Tobias Mädel <t.maedel@alfeld.de>
 * @copyright    MIT-licensed
 *
 */

// rigctl-specific configuration
$rigctl_host = $_ENV["RIGCTL_HOST"];
$rigctl_port = $_ENV["RIGCTL_PORT"];

// Cloudlog-specific parameters
$cloudlog_url = $_ENV["CLOUDLOG_URL"];
$cloudlog_apikey = trim(file_get_contents($_ENV["CLOUDLOG_KEY"]));

// displayed in Cloudlogs Live QSO menu
$radio_name = $_ENV["RADIO_NAME"];

// minimum update interval
$interval = 1;


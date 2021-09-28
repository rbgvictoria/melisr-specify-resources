/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
/**
 * Author:  Niels.Klazenga <Niels.Klazenga at rbg.vic.gov.au>
 * Created: 10/08/2020
 */

USE melisr;

SELECT eventDate, ipt_startDayOfYear(eventDate)
FROM mel_avh_occurrence_core
WHERE ipt_startDayOfYear(eventDate) IS NULL AND eventDate IS NOT NULL
ORDER BY eventDate;

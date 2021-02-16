/**
 * Created by ewong on 2/11/2021.
 */

global with sharing class BatchGTMSubsACVRollUpToLead implements Database.Batchable<sObject>, Database.Stateful {

    global BatchGTMSubsACVRollUpToLead() {

    }

    global Database.QueryLocator start(Database.BatchableContext bc) {

        String query = 'SELECT Id' +
                ' FROM Lead' +
                ' WHERE' +
                ' LIMIT 50000';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Lead> leadList) {



    }

}
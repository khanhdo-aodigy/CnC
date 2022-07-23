/** ******
 * Description : Wrapper class for pagination
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name       Description
 * 20200220            HS         Created Initial Version
 * 
** ******/
public with sharing class PagedResult 
{
    @AuraEnabled
    public Integer pageSize { get; set; }

    @AuraEnabled
    public Integer pageNumber { get; set; }

    @AuraEnabled
    public Integer totalItemCount { get; set; }

    @AuraEnabled
    public List<DataTableColumns> lstDataTableColumns {get;set;}
    
    @AuraEnabled
    public List<sObject> records {get;set;}

    @AuraEnabled
    public String dataTableTitle {get;set;}

    public class DataTableColumns {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled       
        public String fieldName {get;set;}
        @AuraEnabled
        public String type {get;set;}

        public DataTableColumns(String label, String fieldName, String type)
        {
            this.label     = label;
            this.fieldName = fieldName;
            this.type      = type;          
        }
    }
}
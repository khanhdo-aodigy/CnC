//Parser class for Invoice T&C JSON to APEX Var
public class Invoice_TC_JSON2Apex {

    public class Promo {
        public String PromoID;
        public String PromoName;
        public String PromoUrl;
        public String PromoTag;
        public String PromoTitle;
        public String PromoHeroImage;
        public String PromoEndDateLabel;
        public String PromoEndingSoonLabel;
        public PromoTermsAndConditions PromoTermsAndConditions;
        public String PromoShortTitle;
        public String PromoShortDescription;
        public String PromoOverlayImage;
        public String PromoOverlayText;
        public String PromoCTA;
        public Boolean PromoExclusiveTag;
    }

    public String Version;
    public Integer StatusCode;
    public String Timestamp;
    public Result Result;

    public class PromoTermsAndConditions {
        public String ShortDescription;
        public String Content;
    }

    public class Result {
        public List<Promo> Promo;
        public Object Error;
    }
        
      public static Invoice_TC_JSON2Apex parse(String json) {
        return (Invoice_TC_JSON2Apex) System.JSON.deserialize(json, Invoice_TC_JSON2Apex.class);
    }
}
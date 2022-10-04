/** *****
 * Description : Http Request Wrapper class for getsAsia's Inward Payment submission
 * 
 * Change History:
 * Date(YYYYMMDD)       Name                   Ticket                     Description
 * 20220818             HS@aodigy.com        US-Ship-000027          Created Initial Version. 
 * 
** *****/
public class VS_InwardPaymentReqWrapper 
{
  public String messageType {get;set;} 
	public String documentType {get;set;} 
	public String routeId {get;set;} 
	public Data data {get;set;} 

  // ========= L1 =========
  public class Data 
  {
    public String message_version {get;set;} 
    public String sender_id {get;set;} 
    public String recipient_id {get;set;} 
    public Message message {get;set;} 
  }

  // ========= L2 =========
  public class Message 
  {
		public Header header {get;set;} 
		public Cargo cargo {get;set;} 
		public Transport transport {get;set;} 
		public Party party {get;set;} 
		public List<Invoice> invoice {get;set;} 
		public List<Item> item {get;set;} 
		public Summary summary {get;set;} 
		public List<Add_info> add_info {get;set;} 
	}

  // ========= L3 =========
  public class Header 
  {
		public String msg_ref_no {get;set;} 
		public Unique_ref_no unique_ref_no {get;set;} 
		public String declarant_id {get;set;} 
		public String car_type {get;set;} 
		public String dec_type {get;set;} 
		public String dec_stmt_ind {get;set;} 
		public List<Remarks> remarks {get;set;} 
	}

  public class Cargo 
  {
		public String pack_type {get;set;} 
		public Location release_loc {get;set;} 
		public Location receipt_loc {get;set;} 
		public Integer blanket_start_date {get;set;} 
	}

  public class Transport 
  {
		public In_tpt in_tpt {get;set;} 
	}

  public class Party 
  {
		public Declarant declarant {get;set;} 
		public Agent declaring_agent {get;set;} 
		public Agent in_carrier_agent {get;set;} 
		public Agent importer {get;set;} 
	}

  public class Invoice 
  {
		public String inv_no {get;set;} 
		public String inv_date {get;set;} 
    public String inv_term_type {get;set;}
    public Supplier sup_mfr {get;set;}
    public Charge tot_inv_amt {get;set;}
    public Charge frc_charge {get;set;}
    public Charge ins_charge {get;set;}
	}

  public class Item 
  {
		public Integer seq_no {get;set;} 
		public String hs_code {get;set;} 
		public String item_desc {get;set;} 
		public String cty_origin {get;set;} 
		public String brand {get;set;} 
		public String model {get;set;} 
		public Item_qty item_qty {get;set;} 
		public Transaction_value transaction_value {get;set;} 
		public Out_pack_qty out_pack_qty {get;set;} 
		public Duty_tax duty_tax {get;set;} 
		public String item_inv_no {get;set;} 
    public Casc_product casc_product {get; set;}
	}

  public class Summary 
  {
		public Quantity tot_out_pack {get;set;} 
		public Quantity tot_gross_wt {get;set;} 
	}

  public class Add_info 
  {
		public String info_name {get;set;} 
		public String info_text {get;set;}
	}
	

  // ========= L4 =========
  public class Unique_ref_no
  {
		public String cr_uei_no {get;set;} 
		public Integer date_Z {get;set;} // in json: date
		public Integer seq_no {get;set;} 
	}

  public class Remarks 
  {
		public List<Line> line {get;set;} 
	}

  public class Location 
  {
		public String loc_code {get;set;} 
		public String loc_name {get;set;} 
	}

  public class In_tpt 
  {
		public String tpt_mode {get;set;} 
		public String cvy_ref_no {get;set;} 
		public String tpt_id {get;set;} 
		public String master_ship_doc {get;set;} 
		public Integer arrival_date {get;set;} 
		public String loading_port {get;set;} 
	}

  public class Declarant 
  {
		public String person_name {get;set;} 
		public String person_code {get;set;} 
		public String person_phone {get;set;} 
	}
	
  public class Agent 
  {
		public String cr_uei_no {get;set;} 
		public List<Name> name {get;set;} 
	}

  public class Supplier
  {
    public List<Person_Name> person_name {get;set;}
  }

  public class Charge
  {
    public Decimal amt {get;set;}
    public String curr_code {get;set;}
  }

  public class Item_qty 
  {
		public Quantity hs_qty {get;set;} 
		public Quantity tot_dut_qty {get;set;} 
    public Quantity dut_qty {get;set;}
	}
	
  public class Transaction_value 
  {
		public Integer cif_fob_amt {get;set;} 
    public Value unit_price {get;set;}
	}

  public class Casc_product
  {
    public String prod_code {get; set;}
    public Integer prod_qty {get; set;}
    public String prod_qty_uom {get; set;}
    public List<Add_casc_code> add_casc_code {get; set;}
  }

  public class Out_pack_qty 
  {
		public Integer qty {get;set;} 
		public String uom {get;set;} 
	}

  public class Duty_tax 
  {
		public Integer gst_rate {get;set;} 
		public Integer gst_amt {get;set;} 
		public Excise_duty excise_duty {get;set;} 
    public Excise_duty customs_duty {get;set;}
	}

  public class Quantity 
  {
		public Integer qty_value {get;set;} 
		public String qty_uom {get;set;} 
	}

  public class Tot_duty_tax 
  {
		public Integer tot_gst_amt {get;set;} 
		public Integer tot_excise_duty_amt {get;set;} 
		public Integer tot_payable_amt {get;set;} 
	}

  // ========= L5 =========
	public class Line 
  {
		public String line {get;set;} 
	}
	
	public class Name 
  {
		public String name {get;set;} 
	}

  public class Person_Name
  {
    public String person_name {get;set;}
  }

  public class Value
  {
    public String amt; 
		public String curr_code; 
  }
	
	public class Excise_duty 
  {
		public Double duty_rate {get;set;} 
		public String duty_uom {get;set;} 
		public Integer duty_amt {get;set;} 
	}

  public class Add_casc_code
  {
    public String casc_code1 {get; set;}
    public String casc_code2 {get; set;}
    public String casc_code3 {get; set;}
  }
}


// Sample Request Payload
/*
{
  "messageType": "DEC",
  "documentType": "DEC",
  "routeId": "2021082512262426",
  "data": {
    "message_version": "",
    "sender_id": "ETTX.ETTX3002",
    "recipient_id": "",
    "message": {
      "header": {
        "msg_ref_no": "ETRADE1",
        "unique_ref_no": {
          "cr_uei_no": "123456789I",
          "date": 0,
          "seq_no": 0
        },
        "declarant_id": "ETTX.ETTX3002",
        "car_type": "IPTDEC",
        "dec_type": "BKT",
        "dec_stmt_ind": "true",
        "remarks": [
          {
            "line": [
              {
                "line": "IPTDEC BKT 2021041330001"
              }
            ]
          }
        ]
      },
      "cargo": {
        "pack_type": "5",
        "release_loc": {
          "loc_code": "JZ",
          "loc_name": "JURONG FTZ"
        },
        "receipt_loc": {
          "loc_code": "GASPL",
          "loc_name": "GAS SUPPLY (PTE) LTD"
        },
        "blanket_start_date": 20210311
      },
      "transport": {
        "in_tpt": {
          "tpt_mode": "1",
          "cvy_ref_no": "123455BUGGER",
          "tpt_id": "BUGLES",
          "master_ship_doc": "OBL1234",
          "arrival_date": 20111101,
          "loading_port": "HKHKG"
        }
      },
      "party": {
        "declarant": {
          "person_name": "-",
          "person_code": "-",
          "person_phone": "-"
        },
        "declaring_agent": {
          "cr_uei_no": "200105123R",
          "name": [
            {
              "name": "TRADE SERVICES PTE LTD"
            }
          ]
        },
        "freight_forwarder": {
          "cr_uei_no": "197801536N",
          "name": [
            {
              "name": "BASFSOUTHEASTASIAPTELTD"
            }
          ]
        },
        "in_carrier_agent": {
          "cr_uei_no": "200105123R",
          "name": [
            {
              "name": "TRADE SERVICES PTE LTD"
            }
          ]
        },
        "importer": {
          "cr_uei_no": "123456ABC",
          "name": [
            {
              "name": "TN41PARTYNAME"
            }
          ]
        }
      },
      "invoice": [
        {
          "inv_no": "inv1",
          "inv_date": "20210622"
        },
        {
          "inv_no": "inv2",
          "inv_date": "20210622"
        },
        {
          "inv_no": "inv3",
          "inv_date": "20210622"
        }
      ],
      "item": [
        {
          "seq_no": 1,
          "hs_code": "27112111",
          "item_desc": "NATURAL GAS USED AS MOTOR FUEL (TNE)",
          "cty_origin": "MY",
          "brand": "UNBRANDED",
          "model": "12345",
          "item_qty": {
            "hs_qty": {
              "qty_value": 500,
              "qty_uom": "TNE"
            },
            "tot_dut_qty": {
              "qty_value": 500,
              "qty_uom": "KGM"
            },
            "dut_qty": {
              "qty_value": 500,
              "qty_uom": "KGM"
            }
          },
          "transaction_value": {
            "cif_fob_amt": 569800
          },
          "out_pack_qty": {
            "qty": 1,
            "uom": "TUB"
          },
          "duty_tax": {
            "gst_rate": 7,
            "gst_amt": 39893,
            "excise_duty": {
              "duty_rate": 0.2,
              "duty_uom": "KGM",
              "duty_amt": 100
            }
          },
          "item_inv_no": "inv1"
        },
        {
          "seq_no": 2,
          "hs_code": "27112112",
          "item_desc": "NATURAL GAS USED AS MOTOR FUEL (TNE)",
          "cty_origin": "MY",
          "brand": "UNBRANDED",
          "model": "12345",
          "item_qty": {
            "hs_qty": {
              "qty_value": 500,
              "qty_uom": "TNE"
            },
            "tot_dut_qty": {
              "qty_value": 500,
              "qty_uom": "KGM"
            },
            "dut_qty": {
              "qty_value": 500,
              "qty_uom": "KGM"
            }
          },
          "transaction_value": {
            "cif_fob_amt": 569800
          },
          "out_pack_qty": {
            "qty": 1,
            "uom": "TUB"
          },
          "duty_tax": {
            "gst_rate": 7,
            "gst_amt": 39893,
            "excise_duty": {
              "duty_rate": 0.2,
              "duty_uom": "KGM",
              "duty_amt": 100
            }
          },
          "item_inv_no": "inv2"
        },
        {
          "seq_no": 3,
          "hs_code": "27112113",
          "item_desc": "NATURAL GAS USED AS MOTOR FUEL (TNE)",
          "cty_origin": "MY",
          "brand": "UNBRANDED",
          "model": "12345",
          "item_qty": {
            "hs_qty": {
              "qty_value": 500,
              "qty_uom": "TNE"
            },
            "tot_dut_qty": {
              "qty_value": 500,
              "qty_uom": "KGM"
            },
            "dut_qty": {
              "qty_value": 500,
              "qty_uom": "KGM"
            }
          },
          "transaction_value": {
            "cif_fob_amt": 569800
          },
          "out_pack_qty": {
            "qty": 1,
            "uom": "TUB"
          },
          "duty_tax": {
            "gst_rate": 7,
            "gst_amt": 39893,
            "excise_duty": {
              "duty_rate": 0.2,
              "duty_uom": "KGM",
              "duty_amt": 100
            }
          },
          "item_inv_no": "inv3"
        }
      ],
      "summary": {
        "tot_item": 50,
        "tot_cif_fob_amt": 569800,
        "tot_out_pack": {
          "qty_value": 1,
          "qty_uom": "TUB"
        },
        "tot_gross_wt": {
          "qty_value": 5,
          "qty_uom": "TNE"
        },
        "tot_duty_tax": {
          "tot_gst_amt": 39893,
          "tot_excise_duty_amt": 100,
          "tot_payable_amt": 39993
        }
      },
      "add_info": [
        {
          "info_name": "USER_REF_NO",
          "info_text": "IPT-XX1"
        }
      ]
    }
  }
}
*/
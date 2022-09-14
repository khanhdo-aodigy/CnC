/** *****
 * Description : Http Request Wrapper Class for getsAsia's Inward Non Payment submission
 * 
 * Change History:
 * Date(YYYYMMDD)           Name               Ticket                  Description
 * 20220818             HS@aodigy.com       US-Ship-000027       Created Initial Version. 
 * 
** *****/
public class VS_InwardNonPaymentReqWrapper 
{   
    public String messageType; 
	public String documentType; 
	public String routeId; 
	public Data data; 
    
    // ========= L1 =========
    public class Data 
    {
		public String message_version; 
		public String sender_id; 
		public String recipient_id; 
		public Message message; 
	}

    // ========= L2 =========
    public class Message 
    {
		public Header header; 
		public Cargo cargo; 
		public Transport transport; 
		public Party party; 
		public List<Item> item; 
		public Summary summary; 
		public List<Add_info> add_info; 
	}
	
    // ========= L3 =========
    public class Header 
    {
		public Unique_ref_no unique_ref_no; 
		public String declarant_id; 
		public String car_type; 
		public String dec_type; 
		public String dec_stmt_ind; 
		public List<Remarks> remarks; 
	}

    public class Cargo 
    {
		public String pack_type; 
		public Location release_loc; 
		public Location receipt_loc; 
		public Storage_loc storage_loc; 
		public Integer exhibit_temp_imp_start_date; 
	}

    public class Transport 
    {
		public In_tpt in_tpt; 
	}

    public class Party 
    {
		public Declarant declarant; 
		public Agent declaring_agent; 
		public Agent in_carrier_agent; 
		public Agent importer; 
	}

    public class Item 
    {
		public Integer seq_no; 
		public String item_inv_no; 
		public String hs_code; 
		public String item_desc; 
		public String cty_origin; 
		public String brand; 
		public Item_qty item_qty; 
		public Transaction_value transaction_value; 
		public Out_pack_qty out_pack_qty; 
		public String in_house_ship_doc; 
		public String out_house_ship_doc; 
		public Duty_tax duty_tax; 
        public Casc_product casc_product;
	}
	
    public class Summary 
    {
		public Quantity tot_out_pack; 
		public Quantity tot_gross_wt; 
	}


    public class Add_info 
    {
		public String info_name; 
		public String info_text; 
	}
	
    // ========= L4 =========
    public class Unique_ref_no 
    {
		public String cr_uei_no; 
		public Integer date_Z; // in json: date, date is reserved word !!!
		public Integer seq_no; 
	}
	
    public class Remarks 
    {
		public List<Line> line; 
	}

    public class Location 
    {
		public String loc_code; 
		public String loc_name; 
	}

    public class Storage_loc 
    {
		public String loc_code; 
	}
	
    public class In_tpt 
    {
		public String tpt_mode; 
		public String cvy_ref_no; 
		public String tpt_id; 
		public String master_ship_doc; 
		public Integer arrival_date; 
		public String loading_port; 
	}
	
    public class Declarant 
    {
		public String person_code; 
		public String person_name; 
		public String person_phone; 
	}

    public class Agent 
    {
		public String cr_uei_no; 
		public List<Name> name; 
	}

    public class Item_qty 
    {
		public Quantity hs_qty; 
	}

    public class Transaction_value 
    {
		public Value cif_fob_fc; 
        public Value unit_price;
	}

    public class Casc_product
    {
        public String prod_code;
        public Integer prod_qty;
        public String prod_qty_uom;
        public List<Add_casc_code> add_casc_code;
    }

    public class Out_pack_qty 
    {
		public Integer qty; 
		public String uom; 
	}
	
    public class Duty_tax 
    {
		public Integer gst_rate; 
		public Integer gst_amt; 
	}
	
    public class Quantity 
    {
		public Integer qty_value; 
		public String qty_uom; 
	}

    // ========= L5 =========
    public class Name 
    {
		public String name; 
	}

    public class Value 
    {
		public String amt; 
		public String curr_code; 
	}

    public class Line 
    {
		public String line; 
	}
  
    public class Add_casc_code
    {
        public String casc_code1;
        public String casc_code2;
        public String casc_code3;
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
                    "unique_ref_no": {
                        "cr_uei_no": "123456789I",
                        "date": 0,
                        "seq_no": 0
                    },
                    "declarant_id": "ETTX.ETTX3002",
                    "car_type": "INPDEC",
                    "dec_type": "SFZ",
                    "dec_stmt_ind": "true",
                    "remarks": [
                        {
                            "line": [
                                {
                                    "line": "INPDEC 201110230005"
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
                        "loc_code": "KZ",
                        "loc_name": "KEPPEL FTZ"
                    },
                    "storage_loc": {
                        "loc_code": "KZ"
                    },
                    "exhibit_temp_imp_start_date": 20111031
                },
                "transport": {
                    "in_tpt": {
                        "tpt_mode": "1",
                        "cvy_ref_no": "VENUS 1",
                        "tpt_id": "VENUS",
                        "master_ship_doc": "VENUS 1234987",
                        "arrival_date": 20111025,
                        "loading_port": "THBKK"
                    }
                },
                "party": {
                    "declarant": {
                        "person_code": "P00333333",
                        "person_name": "TEST THREE",
                        "person_phone": "68877333"
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
                        "cr_uei_no": "199100001W",
                        "name": [
                            {
                                "name": "AIRTROPOLIS EXPRESS (S) PTE LTD"
                            }
                        ]
                    },
                    "in_carrier_agent": {
                        "cr_uei_no": "1234567890A",
                        "name": [
                            {
                                "name": "ABC PTE LTD"
                            }
                        ]
                    },
                    "importer": {
                        "cr_uei_no": "196400287H",
                        "name": [
                            {
                                "name": "CARRIER SINGAPORE (PTE) LIMITED"
                            }
                        ]
                    },
                    "out_carrier_agent": {
                        "cr_uei_no": "1234567890A",
                        "name": [
                            {
                                "name": "ABC PTE LTD"
                            }
                        ]
                    },
                    "consignee": {
                        "name": [
                            {
                                "name": "CONSIGNEE"
                            }
                        ],
                        "address": [
                            {
                                "address": "123 JALAN BUSAH PUNYA"
                            }
                        ],
                        "city": "SINPGAPORE",
                        "cty_code": "SG"
                    }
                },
                "licence": {
                    "lic_no": [
                        {
                            "lic_no": "IM0F00001"
                        }
                    ]
                },
                "item": [
                    {
                        "seq_no": 1,
                        "item_inv_no": "inv1",
                        "hs_code": "39262060",
                        "item_desc": "ARTICLES OF APPAREL FOR PROTECTION",
                        "cty_origin": "TH",
                        "brand": "SFZ BRAND",
                        "item_qty": {
                            "hs_qty": {
                                "qty_value": 1000,
                                "qty_uom": "KGM"
                            }
                        },
                        "transaction_value": {
                            "cif_fob_fc":{
                                "amt": "350",
                                "curr_code": "USD"
                            }
                        },
                        "out_pack_qty": {
                            "qty": 6,
                            "uom": "CTN"
                        },
                        "in_house_ship_doc": "VENUS 1234",
                        "out_house_ship_doc": "OUT OBL",
                        "duty_tax": {
                            "gst_rate": 7,
                            "gst_amt": 2450
                        }
                    },
                    {
                        "seq_no": 2,
                        "item_inv_no": "inv1",
                        "hs_code": "39262060",
                        "item_desc": "ARTICLES OF APPAREL FOR PROTECTION",
                        "cty_origin": "TH",
                        "brand": "SFZ BRAND",
                        "item_qty": {
                            "hs_qty": {
                                "qty_value": 1000,
                                "qty_uom": "KGM"
                            }
                        },
                        "transaction_value": {
                            "cif_fob_fc":{
                                "amt": "750",
                                "curr_code": "USD"
                            }
                        },
                        "out_pack_qty": {
                            "qty": 6,
                            "uom": "CTN"
                        },
                        "in_house_ship_doc": "VENUS 1234",
                        "out_house_ship_doc": "OUT OBL",
                        "duty_tax": {
                            "gst_rate": 7,
                            "gst_amt": 2450
                        }
                    }
                ],
                "summary": {
                    "tot_item": 2,
                    "tot_cif_fob_amt": 35000,
                    "tot_out_pack": {
                        "qty_value": 6,
                        "qty_uom": "CTN"
                    },
                    "tot_gross_wt": {
                        "qty_value": 1,
                        "qty_uom": "TNE"
                    },
                    "tot_duty_tax": {
                        "tot_gst_amt": 2450,
                        "tot_payable_amt": 0
                    }
                },
                "add_info": [
                    {
                        "info_name": "USER_REF_NO",
                        "info_text": "test 14"
                    }
                ]
            }
        }
    }

*/

}
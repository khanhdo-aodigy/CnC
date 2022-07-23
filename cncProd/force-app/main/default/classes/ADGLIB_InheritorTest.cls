/*
 * Copyright (c) 2017 FinancialForce.com, inc.  All rights reserved.
 */
@isTest
public class ADGLIB_InheritorTest
{
 	@isTest
    public static void canInstantiateMultipleInterfaceInheritor()
    {
        ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
        Object inheritor = mocks.mock(ADGLIB_Inheritor.class);
        System.assert(inheritor instanceof ADGLIB_Inheritor.IA);
        System.assert(inheritor instanceof ADGLIB_Inheritor.IB);
        System.assert(inheritor instanceof ADGLIB_Inheritor.IC);
    }

 	@isTest
    public static void canStubMultipleInterfaceInheritor()
    {
        ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
        ADGLIB_Inheritor inheritor = (ADGLIB_Inheritor)mocks.mock(ADGLIB_Inheritor.class);

        mocks.startStubbing();
        mocks.when(inheritor.doA()).thenReturn('Did not do A');
        mocks.when(inheritor.doB()).thenReturn('Did not do B');
        mocks.when(inheritor.doC()).thenReturn('Did not do C');
        mocks.stopStubbing();
        
        System.assertEquals('Did not do A', inheritor.doA());
        System.assertEquals('Did not do B', inheritor.doB());
        System.assertEquals('Did not do C', inheritor.doC());
    }
}
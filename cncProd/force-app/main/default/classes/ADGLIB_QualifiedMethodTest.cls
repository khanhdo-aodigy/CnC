/*
 * Copyright (c) 2016-2017 FinancialForce.com, inc.  All rights reserved.
 */
@isTest
public with sharing class ADGLIB_QualifiedMethodTest
{
	@isTest
	private static void equalsReturnsExpectedResults()
	{
		//Given
		ADGLIB_QualifiedMethod qm1 = new ADGLIB_QualifiedMethod('Type1', 'Method1', new List<Type>{ Integer.class } );
		ADGLIB_QualifiedMethod qm2 = new ADGLIB_QualifiedMethod('Type1', 'Method1', new List<Type>{ Integer.class } );
		ADGLIB_QualifiedMethod qm3 = new ADGLIB_QualifiedMethod('Type1', 'Method1', new List<Type>{ String.class } );
		ADGLIB_QualifiedMethod qm4 = new ADGLIB_QualifiedMethod('Type2', 'Method2', new List<Type>{ Integer.class, String.class, ADGLIB_QualifiedMethodTest.class } );
		ADGLIB_QualifiedMethod qm5 = new ADGLIB_QualifiedMethod('', '', new List<Type>{} );
		ADGLIB_QualifiedMethod qm6 = new ADGLIB_QualifiedMethod(null, null, null );

		//When/thens
		System.assertEquals(qm1, qm1);
		System.assertEquals(qm1, qm2);
		System.assertNotEquals(qm1, qm3);
		System.assertNotEquals(qm1, qm4);
		System.assertNotEquals(qm1, qm5);
		System.assertNotEquals(qm1, qm6);

		System.assertEquals(qm2, qm2);
		System.assertNotEquals(qm2, qm3);
		System.assertNotEquals(qm2, qm4);
		System.assertNotEquals(qm2, qm5);
		System.assertNotEquals(qm2, qm6);

		System.assertEquals(qm3, qm3);
		System.assertNotEquals(qm3, qm4);
		System.assertNotEquals(qm3, qm5);
		System.assertNotEquals(qm3, qm6);

		System.assertEquals(qm4, qm4);
		System.assertNotEquals(qm4, qm5);
		System.assertNotEquals(qm4, qm6);

		System.assertEquals(qm5, qm5);
		System.assertNotEquals(qm5, qm6);

		System.assertEquals(qm6, qm6);
	}

	@isTest
	private static void hashCodeReturnsExpectedResults()
	{
		//Given
		ADGLIB_QualifiedMethod qm1 = new ADGLIB_QualifiedMethod('Type1', 'Method1', new List<Type>{ Integer.class } );
		ADGLIB_QualifiedMethod qm2 = new ADGLIB_QualifiedMethod('Type1', 'Method1', new List<Type>{ Integer.class } );
		ADGLIB_QualifiedMethod qm3 = new ADGLIB_QualifiedMethod('Type1', 'Method1', new List<Type>{ String.class } );
		ADGLIB_QualifiedMethod qm4 = new ADGLIB_QualifiedMethod('Type2', 'Method2', new List<Type>{ Integer.class, String.class, ADGLIB_QualifiedMethodTest.class } );
		ADGLIB_QualifiedMethod qm5 = new ADGLIB_QualifiedMethod('', '', new List<Type>{} );
		ADGLIB_QualifiedMethod qm6 = new ADGLIB_QualifiedMethod(null, null, null );

		//When/thens
		System.assertEquals(qm1.hashCode(), qm1.hashCode());
		System.assertEquals(qm1.hashCode(), qm2.hashCode());
		System.assertNotEquals(qm1.hashCode(), qm3.hashCode());
		System.assertNotEquals(qm1.hashCode(), qm4.hashCode());
		System.assertNotEquals(qm1.hashCode(), qm5.hashCode());
		System.assertNotEquals(qm1.hashCode(), qm6.hashCode());

		System.assertEquals(qm2.hashCode(), qm2.hashCode());
		System.assertNotEquals(qm2.hashCode(), qm3.hashCode());
		System.assertNotEquals(qm2.hashCode(), qm4.hashCode());
		System.assertNotEquals(qm2.hashCode(), qm5.hashCode());
		System.assertNotEquals(qm2.hashCode(), qm6.hashCode());

		System.assertEquals(qm3.hashCode(), qm3.hashCode());
		System.assertNotEquals(qm3.hashCode(), qm4.hashCode());
		System.assertNotEquals(qm3.hashCode(), qm5.hashCode());
		System.assertNotEquals(qm3.hashCode(), qm6.hashCode());

		System.assertEquals(qm4.hashCode(), qm4.hashCode());
		System.assertNotEquals(qm4.hashCode(), qm5.hashCode());
		System.assertNotEquals(qm4.hashCode(), qm6.hashCode());

		System.assertEquals(qm5.hashCode(), qm5.hashCode());
		System.assertNotEquals(qm5.hashCode(), qm6.hashCode());

		System.assertEquals(qm6.hashCode(), qm6.hashCode());
	}

	@isTest
	public static void toStringReturnsExpectedResult()
	{
		System.assertEquals('MyClass.MyMethod(Integer)', new ADGLIB_QualifiedMethod('MyClass', 'MyMethod', new List<Type>{ Integer.class }).toString());
	}

	@isTest
	private static void equalsReturnsExpectedResultsForHasDependentMocks()
	{
		//Given
		String instance = 'My object instance';
		String instance2 = 'My other object instance';
		ADGLIB_QualifiedMethod qm1 = new ADGLIB_QualifiedMethod('Type1', 'Method1', new List<Type>{ Integer.class } );
		ADGLIB_QualifiedMethod qm2 = new ADGLIB_QualifiedMethod('Type1', 'Method1', new List<Type>{ Integer.class }, instance);
		ADGLIB_QualifiedMethod qm3 = new ADGLIB_QualifiedMethod('Type1', 'Method1', new List<Type>{ Integer.class }, instance);
		ADGLIB_QualifiedMethod qm4 = new ADGLIB_QualifiedMethod('Type1', 'Method1', new List<Type>{ Integer.class }, instance2);

		//When/thens
		ADGLIB_ApexMocksConfig.HasIndependentMocks = false;
		
		System.assertEquals(qm1, qm2);
		System.assertEquals(qm1, qm3);
		System.assertEquals(qm1, qm4);

		ADGLIB_ApexMocksConfig.HasIndependentMocks = true;

		System.assertNotEquals(qm1, qm2);
		System.assertNotEquals(qm1, qm3);
		System.assertNotEquals(qm1, qm4);

		System.assertEquals(qm2, qm3);
		System.assertNotEquals(qm2, qm4);

		System.assertNotEquals(qm3, qm4);
	}

	@isTest
	private static void hashCodeReturnsExpectedResultsForHasDependentMocks()
	{
		//Given
		String instance = 'My object instance';
		String instance2 = 'My other object instance';
		ADGLIB_QualifiedMethod qm1 = new ADGLIB_QualifiedMethod('Type1', 'Method1', new List<Type>{ Integer.class } );
		ADGLIB_QualifiedMethod qm2 = new ADGLIB_QualifiedMethod('Type1', 'Method1', new List<Type>{ Integer.class }, instance);
		ADGLIB_QualifiedMethod qm3 = new ADGLIB_QualifiedMethod('Type1', 'Method1', new List<Type>{ Integer.class }, instance);
		ADGLIB_QualifiedMethod qm4 = new ADGLIB_QualifiedMethod('Type1', 'Method1', new List<Type>{ Integer.class }, instance2);

		//When/thens
		ADGLIB_ApexMocksConfig.HasIndependentMocks = false;
		
		System.assertEquals(qm1.hashCode(), qm2.hashCode());
		System.assertEquals(qm1.hashCode(), qm3.hashCode());
		System.assertEquals(qm1.hashCode(), qm4.hashCode());

		ADGLIB_ApexMocksConfig.HasIndependentMocks = true;

		System.assertNotEquals(qm1.hashCode(), qm2.hashCode());
		System.assertNotEquals(qm1.hashCode(), qm3.hashCode());
		System.assertNotEquals(qm1.hashCode(), qm4.hashCode());

		System.assertEquals(qm2.hashCode(), qm3.hashCode());
		System.assertNotEquals(qm2.hashCode(), qm4.hashCode());

		System.assertNotEquals(qm3.hashCode(), qm4.hashCode());
	}
}
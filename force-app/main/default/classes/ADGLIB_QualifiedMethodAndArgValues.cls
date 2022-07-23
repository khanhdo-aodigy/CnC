/*
 Copyright (c) 2016-2017 FinancialForce.com, inc.  All rights reserved.
 */

/**
 * @group Core
 */
public with sharing class ADGLIB_QualifiedMethodAndArgValues
{
	private final ADGLIB_QualifiedMethod qm;
	private final ADGLIB_MethodArgValues args;
	private final Object mockInstance;

	public ADGLIB_QualifiedMethodAndArgValues(ADGLIB_QualifiedMethod qm, ADGLIB_MethodArgValues args, Object mockInstance)
	{
		this.qm = qm;
		this.args = args;
		this.mockInstance = mockInstance;
	}

	public ADGLIB_QualifiedMethod getQualifiedMethod()
	{
		return qm;
	}

	public ADGLIB_MethodArgValues getMethodArgValues()
	{
		return args;
	}

	public Object getMockInstance()
	{
		return mockInstance;
	}

	public override String toString()
	{
		return qm + ' with args: [' + String.join(args.argValues, '],[') + ']';
	}
}
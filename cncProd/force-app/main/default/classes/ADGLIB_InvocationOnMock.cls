/*
 Copyright (c) 2017 FinancialForce.com, inc.  All rights reserved.
 */

/**
 *	An invocation on a mock.
 *	A place holder for mock, the method that was called and the arguments that were passed.
 *	@group Core
 */
public with sharing class ADGLIB_InvocationOnMock
{
	private ADGLIB_QualifiedMethod qm;
	private ADGLIB_MethodArgValues methodArg;
	private Object mockInstance;

	/**
	 *	Constructor for the class.
	 *  @param qm The ADGLIB_QualifiedMethod instance to be stored.
	 *  @param args The ADGLIB_MethodArgValues instance to be stored.
	 *  @param mockInstance The mock instance to be stored.
	 */
	public ADGLIB_InvocationOnMock(ADGLIB_QualifiedMethod qm, ADGLIB_MethodArgValues args, Object mockInstance)
	{
		this.qm = qm;
		this.methodArg = args;
		this.mockInstance = mockInstance;
	}

	/**
	 *	Returns the argument at the given index.
	 *  @param index The index of the wanted argument.
	 *  @throws ApexMocksException in case the index is out of range.
	 *  @return The argument at the given index.
	 */
	public Object getArgument(Integer index)
	{
		validateIndex(index);
		return methodArg.argValues[index];
	}

	/**
	 *	Returns the list of arguments passed to the method.
	 *  @return The list of arguments.
	 */
	public List<Object> getArguments()
	{
		return methodArg.argValues;
	}

	/**
	 *	Returns ADGLIB_MethodArgValues instance that represents the arguments passed to the method.
	 *  @return The ADGLIB_MethodArgValues instance that represents the arguments passed to the method.
	 */
	public ADGLIB_MethodArgValues getMethodArgValues()
	{
		return methodArg;
	}

	/**
	 *	Returns the ADGLIB_QualifiedMethod instance that represent the fully qualified method called within the invocation.
	 *	@return The method stored in the invocation.
	 */
	public ADGLIB_QualifiedMethod getMethod()
	{
		return qm;
	}

	/**
	 *	Returns the mock object on which the invocation occurs.
	 *	@return The mock object on which the invocation occurs.
	 */
	public Object getMock()
	{
		return mockInstance;
	}

	private void validateIndex(Integer index)
	{
		if(index < 0 || index >= methodArg.argValues.size())
		{
			throw new ADGLIB_ApexMocks.ApexMocksException('Invalid index, must be greater or equal to zero and less of ' + methodArg.argValues.size()+'.');
		}
	}
}
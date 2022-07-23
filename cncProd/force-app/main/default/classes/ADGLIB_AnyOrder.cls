/*
 Copyright (c) 2017 FinancialForce.com, inc.  All rights reserved.
 */

/**
 *	'Classic' invocation verifier - checks that a method was called with the given arguments the expected number of times.
 *	The order of method calls is not important.
 *	@group Core
 */
public class ADGLIB_AnyOrder extends ADGLIB_MethodVerifier
{
	/*
	 * Verifies a method was invoked the expected number of times, with the expected arguments.
	 * @param qualifiedMethod The method to be verified.
	 * @param methodArg The arguments of the method that needs to be verified.
	 * @param verificationMode The verification mode that holds the setting about how the verification should be performed.
	 */
	protected override void verify(
		ADGLIB_QualifiedMethod qm,
		ADGLIB_MethodArgValues methodArg,
		ADGLIB_VerificationMode verificationMode)
	{
		Integer methodCount = getMethodCount(qm, methodArg);

		String qualifier = '';
		Integer expectedCount = null;

		if((verificationMode.VerifyMin == verificationMode.VerifyMax) && methodCount != verificationMode.VerifyMin)
		{
			expectedCount = verificationMode.VerifyMin;
		}
		else if (verificationMode.VerifyMin != null && verificationMode.VerifyMin > methodCount)
		{
			expectedCount = verificationMode.VerifyMin;
			qualifier = ' or more times';
		}
		else if (verificationMode.VerifyMax != null && verificationMode.VerifyMax < methodCount)
		{
			expectedCount = verificationMode.VerifyMax;
			qualifier = ' or fewer times';
		}

		if (expectedCount != null)
		{
			throwException(qm, '', expectedCount, qualifier, methodCount, verificationMode.CustomAssertMessage);
		}
	}

	private Integer getMethodCount(ADGLIB_QualifiedMethod qm, ADGLIB_MethodArgValues methodArg)
	{
		List<ADGLIB_IMatcher> matchers = ADGLIB_Match.Matching ? ADGLIB_Match.getAndClearMatchers(methodArg.argValues.size()) : null;
		Integer retval = 0;

		List<ADGLIB_MethodArgValues> methodArgs =
			ADGLIB_MethodCountRecorder.getMethodArgumentsByTypeName().get(qm);

		if (methodArgs != null)
		{
			if (matchers != null)
			{
				for (ADGLIB_MethodArgValues args : methodArgs)
				{
					if (ADGLIB_Match.matchesAllArgs(args, matchers))
					{
						capture(matchers);

						retval ++;
					}
				}
			}
			else
			{
				return countCalls(methodArgs, methodArg);
			}
		}

		return retval;
	}

	private Integer countCalls(List<ADGLIB_MethodArgValues> methodArgs, ADGLIB_MethodArgValues methodArg)
	{
		Integer count = 0;

		for(ADGLIB_MethodArgValues arg: methodArgs)
		{
			if( arg == methodArg) count++;
		}

		return count;
	}

	/*
	 * Method that validate the verification mode used in the verify.
	 * Not all the methods from the ADGLIB_VerificationMode are implemented for the different classes that extends the ADGLIB_MethodVerifier.
	 * The error is thrown at run time, so this method is called in the method that actually performs the verify.
	 * @param verificationMode The verification mode that have to been verified.
	 * @throws Exception with message for the ADGLIB_VerificationMode not implemented.
	 */
	protected override void validateMode(ADGLIB_VerificationMode verificationMode)
	{
		if(verificationMode.Method == ADGLIB_VerificationMode.ModeName.CALLS)
		{
			throw new ADGLIB_ApexMocks.ApexMocksException(
				'The calls() method is available only in the InOrder Verification.');
		}
	}
}
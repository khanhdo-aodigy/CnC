/*
 * Copyright (c) 2017 FinancialForce.com, inc.  All rights reserved.
 */
@IsTest
private class ADGLIB_SystemTest
{
	@IsTest
	private static void assertEquals_WithNoMatchers_ShouldThrowException()
	{
		try
		{
			ADGLIB_System.assertEquals('Test String', 'Test String');
			System.assert(false, 'Expected exception');
		}
		catch (ADGLIB_ApexMocks.ApexMocksException e)
		{
			System.assertEquals('ADGLIB_System.assertEquals expects you to register exactly 1 ADGLIB_IMatcher (typically through the helpers in ADGLIB_Match).', e.getMessage());
		}
	}

	@IsTest
	private static void assertEquals_WithTooManyMatchers_ShouldThrowException()
	{
		//Register matchers prematurely
		ADGLIB_Match.stringStartsWith('Test S');
		ADGLIB_Match.stringEndsWith('t String');
		ADGLIB_Match.stringIsNotBlank();

		try
		{
			ADGLIB_System.assertEquals(ADGLIB_Match.stringStartsWith('Test S'), 'Test String');
			System.assert(false, 'Expected exception');
		}
		catch (ADGLIB_ApexMocks.ApexMocksException e)
		{
			System.assertEquals('ADGLIB_System.assertEquals expects you to register exactly 1 ADGLIB_IMatcher (typically through the helpers in ADGLIB_Match).', e.getMessage());
		}
	}

	@IsTest
	private static void assertEquals_WithMismatch_ShouldThrowException()
	{
		try
		{
			ADGLIB_System.assertEquals(ADGLIB_Match.stringStartsWith('Test X'), 'Test String');
			System.assert(false, 'Expected exception');
		}
		catch (ADGLIB_ApexMocks.ApexMocksException e)
		{
			String expected = 'Actual: Test String';
			String actual = e.getMessage();
			System.assert(actual.contains(expected), 'Expected: ' + expected + ', Actual: ' + actual);
		}
	}

	@IsTest
	private static void assertEquals_WithMatch_ShouldPass()
	{
		ADGLIB_System.assertEquals(ADGLIB_Match.stringStartsWith('Test S'), 'Test String');
	}

	@IsTest
	private static void assertEquals_WithCombinedMatcher_ShouldPass()
	{
		ADGLIB_System.assertEquals(ADGLIB_Match.allOf(
				ADGLIB_Match.stringStartsWith('Test S'),
				ADGLIB_Match.stringEndsWith('t String'),
				ADGLIB_Match.stringIsNotBlank())
			, 'Test String');
	}

	@IsTest
	private static void assertEquals_WithCustomMessage_WithNoMatchers_ShouldThrowException()
	{
		try
		{
			ADGLIB_System.assertEquals('Test String', 'Test String', 'My Custom Message');
			System.assert(false, 'Expected exception');
		}
		catch (ADGLIB_ApexMocks.ApexMocksException e)
		{
			System.assertEquals('ADGLIB_System.assertEquals expects you to register exactly 1 ADGLIB_IMatcher (typically through the helpers in ADGLIB_Match).', e.getMessage());
		}
	}

	@IsTest
	private static void assertEquals_WithCustomMessage_WithTooManyMatchers_ShouldThrowException()
	{
		//Register matchers prematurely
		ADGLIB_Match.stringStartsWith('Test S');
		ADGLIB_Match.stringEndsWith('t String');
		ADGLIB_Match.stringIsNotBlank();

		try
		{
			ADGLIB_System.assertEquals(ADGLIB_Match.stringStartsWith('Test S'), 'Test String', 'My Custom Message');
			System.assert(false, 'Expected exception');
		}
		catch (ADGLIB_ApexMocks.ApexMocksException e)
		{
			System.assertEquals('ADGLIB_System.assertEquals expects you to register exactly 1 ADGLIB_IMatcher (typically through the helpers in ADGLIB_Match).', e.getMessage());
		}
	}

	@IsTest
	private static void assertEquals_WithCustomMessage_WithMismatch_ShouldThrowException()
	{
		try
		{
			ADGLIB_System.assertEquals(ADGLIB_Match.stringStartsWith('Test X'), 'Test String', 'My Custom Message');
			System.assert(false, 'Expected exception');
		}
		catch (ADGLIB_ApexMocks.ApexMocksException e)
		{
			String expected = 'Actual: Test String -- My Custom Message';
			String actual = e.getMessage();
			System.assert(actual.contains(expected), 'Expected: ' + expected + ', Actual: ' + actual);
		}
	}

	@IsTest
	private static void assertEquals_WithCustomMessage_WithMatch_ShouldPass()
	{
		ADGLIB_System.assertEquals(ADGLIB_Match.stringStartsWith('Test S'), 'Test String', 'My Custom Message');
	}

	@IsTest
	private static void assertEquals_WithCustomMessage_WithCombinedMatcher_ShouldPass()
	{
		ADGLIB_System.assertEquals(ADGLIB_Match.allOf(
				ADGLIB_Match.stringStartsWith('Test S'),
				ADGLIB_Match.stringEndsWith('t String'),
				ADGLIB_Match.stringIsNotBlank())
			, 'Test String', 'My Custom Message');
	}
}
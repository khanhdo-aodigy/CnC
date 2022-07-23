/*
 Copyright (c) 2017 FinancialForce.com, inc.  All rights reserved.
 */

/**
 * @nodoc
 */
@isTest
private class ADGLIB_AnyOrderTest
{
	private static final String BASIC_VERIFY_ASSERTION_MESSAGE = 'Expected : {0}, Actual: {1} -- Wanted but not invoked: ';

	/*
	 *	replicating the apex mocks tests with the new syntax
	 */

	@isTest
	private static void whenVerifyMultipleCallsWithMatchersShouldReturnCorrectMethodCallCounts()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('bob');
		mockList.add('fred');

		// Then
		((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.times(2))).add(ADGLIB_Match.anyString());
		((ADGLIB_MyList.IList) mocks.verify(mockList)).add('fred');
		((ADGLIB_MyList.IList) mocks.verify(mockList)).add(ADGLIB_Match.stringContains('fred'));
	}

	@isTest
	private static void whenVerifyWithCombinedMatchersShouldReturnCorrectMethodCallCounts()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('bob');
		mockList.add('fred');

		// Then
		((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.never())).add(
			(String)ADGLIB_Match.allOf(ADGLIB_Match.eq('bob'), ADGLIB_Match.stringContains('re'))
		);

		((ADGLIB_MyList.IList) mocks.verify(mockList)).add(
			(String)ADGLIB_Match.allOf(ADGLIB_Match.eq('fred'), ADGLIB_Match.stringContains('re'))
		);

		((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.times(2))).add(
			(String)ADGLIB_Match.anyOf(ADGLIB_Match.eq('bob'), ADGLIB_Match.eq('fred'))
		);

		((ADGLIB_MyList.IList) mocks.verify(mockList)).add(
			(String)ADGLIB_Match.anyOf(ADGLIB_Match.eq('bob'), ADGLIB_Match.eq('jack'))
		);

		((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.times(2))).add(
			(String)ADGLIB_Match.noneOf(ADGLIB_Match.eq('jack'), ADGLIB_Match.eq('tim'))
		);

		((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.times(2))).add(
			(String)ADGLIB_Match.noneOf(
				ADGLIB_Match.anyOf(ADGLIB_Match.eq('jack'), ADGLIB_Match.eq('jill')),
				ADGLIB_Match.allOf(ADGLIB_Match.eq('tim'), ADGLIB_Match.stringContains('i'))
			)
		);

		((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.times(2))).add(
			(String)ADGLIB_Match.isNot(ADGLIB_Match.eq('jack'))
		);
	}

	@isTest
	private static void whenVerifyCustomMatchersCanBeUsed()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.get(1);
		mockList.get(2);
		mockList.get(3);
		mockList.get(4);
		mockList.get(5);

		// Then
		((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.times(3))).get((Integer)ADGLIB_Match.matches(new isOdd()));
		((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.times(2))).get((Integer)ADGLIB_Match.matches(new isEven()));
	}

	@isTest
	private static void verifyMultipleMethodCallsWithSameSingleArgument()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('bob');
		mockList.add('bob');

		// Then
		((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.times(2))).add('bob');
	}

	@isTest
	private static void verifyMethodNotCalled()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.get(0);

		// Then
		((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.never())).add('bob');
		((ADGLIB_MyList.IList) mocks.verify(mockList)).get(0);
	}

	@isTest
	private static void verifySingleMethodCallWithMultipleArguments()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.set(0, 'bob');

		// Then
		((ADGLIB_MyList.IList) mocks.verify(mockList)).set(0, 'bob');
		((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.never())).set(0, 'fred');
	}

	@isTest
	private static void verifyMethodCallWhenNoCallsBeenMadeForType()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// Then
		((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.never())).add('bob');
	}

	@isTest
	private static void whenVerifyMethodNeverCalledMatchersAreReset()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('bob');

		// Then
		((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.never())).get(ADGLIB_Match.anyInteger());
		((ADGLIB_MyList.IList) mocks.verify(mockList)).add(ADGLIB_Match.anyString());
	}

	/*
	 *	times
	 */

	@isTest
	private static void verifyTimesMethodHasBeenCalled()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('bob');
		mockList.add('bob');
		mockList.add('bob');

		// Then
		((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.times(3))).add('bob');
	}

	@isTest
	private static void verifyTimesMethodHasBeenCalledWithMatchers()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('bob1');
		mockList.add('bob2');
		mockList.add('bob3');

		// Then
		((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.times(3))).add(ADGLIB_Match.anyString());
	}

	@isTest
	private static void thatVerifyTimesMethodFailsWhenCalledLessTimes()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('bob');
		mockList.add('bob');
		mockList.add('bob');

		// Then
		try
		{
			((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.times(4))).add('bob');

			System.assert(false, 'an exception was expected');
		}
		catch(Exception exc)
		{
			assertFailMessage(exc.getMessage(), 4, 3);
		}
	}

	@isTest
	private static void thatVerifyTimesMethodFailsWhenCalledMoreTimes()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('bob');
		mockList.add('bob');
		mockList.add('bob');

		// Then
		try
		{
			((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.times(2))).add('bob');

			System.assert(false, 'an exception was expected');
		}
		catch(Exception exc)
		{
			assertFailMessage(exc.getMessage(), 2, 3);
		}
	}

	@isTest
	private static void thatVerifyTimesMethodFailsWhenCalledLessTimesWithMatchers()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('bob');
		mockList.add('bob');
		mockList.add('bob');

		// Then
		try
		{
			((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.times(4))).add(ADGLIB_Match.anyString());

			System.assert(false, 'an exception was expected');
		}
		catch(Exception exc)
		{
			assertFailMessage(exc.getMessage(), 4, 3);
		}
	}

	@isTest
	private static void thatVerifyTimesMethodFailsWhenCalledMoreTimesWithMatchers()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('bob');
		mockList.add('bob');
		mockList.add('bob');

		// Then
		try
		{
			((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.times(2))).add(ADGLIB_Match.anyString());

			System.assert(false, 'an exception was expected');
		}
		catch(Exception exc)
		{
			assertFailMessage(exc.getMessage(), 2, 3);
		}
	}

	/*
	 *	description
	 */

	@isTest
	private static void thatCustomMessageIsAdded()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('bob');
		mockList.add('bob');
		mockList.add('bob');

		String customAssertMessage = 'Custom message to explain the reason of the verification';

		// Then
		try
		{
			((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.times(2).description(customAssertMessage))).add(ADGLIB_Match.anyString());

			System.assert(false, 'an exception was expected');
		}
		catch(Exception exc)
		{
			String exceptionMessage = exc.getMessage();

			String expectedMessage =
				String.format(BASIC_VERIFY_ASSERTION_MESSAGE,
					new List<String>{'2', '3'}) + ADGLIB_MyList.getStubClassName() + '.add(String). ' + customAssertMessage + '.';

			System.assertEquals(expectedMessage, exceptionMessage,
				'The exception was caught, but the message was not as expected. ' +
				'Expected: [' + expectedMessage + '],  Actual: [' + exceptionMessage + '].');
		}
	}

	/*
	 *	atLeast
	 */

	@isTest
	private static void thatVerifiesAtLeastNumberOfTimes()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('bob');
		mockList.add('fred');
		mockList.add('bob');
		mockList.add('bob');

		// Then
		((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.atLeast(2))).add('bob');
	}

	@isTest
	private static void thatVerifiesAtLeastNumberOfTimesWhenIsCalledMoreTimes()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('bob');
		mockList.add('fred');
		mockList.add('bob');
		mockList.add('fred');
		mockList.add('bob');
		mockList.add('fred');

		// Then
		((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.atLeast(2))).add('bob');
	}

	@isTest
	private static void thatThrownExceptionIfCalledLessThanAtLeastNumberOfTimes()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('bob');
		mockList.add('fred');
		mockList.add('bob');

		// Then
		try
		{
			((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.atLeast(3))).add('bob');

			System.assert(false, 'an exception was expected because we are asserting that the method is called 3 times when instead is called only twice');
		}
		catch(ADGLIB_ApexMocks.ApexMocksException ex)
		{
			String expectedMessage = 'Expected : 3 or more times, Actual: 2 -- Wanted but not invoked: ' + ADGLIB_MyList.getStubClassName() + '.add(String).';
			String actualMessage = ex.getMessage();
			System.assertEquals(expectedMessage, actualMessage,
				'the exception has been caught as expected, however the message is not as expected');
		}
	}

	@isTest
	private static void thatVerifiesAtLeastNumberOfTimesWithMatchers()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('bob');
		mockList.add('fred');

		// Then
		((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.atLeast(2))).add(ADGLIB_Match.anyString());
	}

	@isTest
	private static void thatVerifiesAtLeastNumberOfTimesWhenIsCalledMoreTimesWithMatchers()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('bob');
		mockList.add('fred');
		mockList.add('fred');
		mockList.add('fred');

		// Then
		((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.atLeast(2))).add(ADGLIB_Match.anyString());
	}

	@isTest
	private static void thatThrownExceptionIfCalledLessThanAtLeastNumberOfTimesWithMatchers()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('bob');
		mockList.add('fred');

		// Then
		try
		{
			((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.atLeast(3))).add(ADGLIB_Match.anyString());

			System.assert(false, 'an exception was expected because we are asserting that the method is called 3 times when instead is called only twice');
		}
		catch(ADGLIB_ApexMocks.ApexMocksException ex)
		{
			String expectedMessage = 'Expected : 3 or more times, Actual: 2 -- Wanted but not invoked: ' + ADGLIB_MyList.getStubClassName() + '.add(String).';
			String actualMessage = ex.getMessage();
			System.assertEquals(expectedMessage, actualMessage,
				'the exception has been caught as expected, however the message is not as expected');
		}
	}

	/*
	 *	atMost
	 */

	@isTest
	private static void thatVerifiesAtMostNumberOfTimes()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('bob');
		mockList.add('fred');
		mockList.add('bob');
		mockList.add('bob');
		mockList.add('fred');

		// Then
		((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.atMost(5))).add('bob');
	}

	@isTest
	private static void thatVerifiesAtMostSameNumberOfTimes()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('bob');
		mockList.add('fred');
		mockList.add('bob');
		mockList.add('bob');
		mockList.add('fred');

		// Then
		((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.atMost(3))).add('bob');
	}

	@isTest
	private static void thatThrownExceptionIfCalledMoreThanAtMostNumberOfTimes()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('bob');
		mockList.add('fred');
		mockList.add('fred');
		mockList.add('bob');
		mockList.add('bob');
		mockList.add('bob');
		mockList.add('fred');

		// Then
		try
		{
			((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.atMost(3))).add('bob');

			System.assert(false, 'an exception was expected because we are asserting that the method is called 3 times when instead is called four times');
		}
		catch(ADGLIB_ApexMocks.ApexMocksException ex)
		{
			String expectedMessage = 'Expected : 3 or fewer times, Actual: 4 -- Wanted but not invoked: ' + ADGLIB_MyList.getStubClassName() + '.add(String).';
			String actualMessage = ex.getMessage();
			System.assertEquals(expectedMessage, actualMessage,
				'the exception has been caught as expected, however the message is not as expected');
		}
	}

	@isTest
	private static void thatVerifiesAtMostNumberOfTimesWithMatchers()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('bob');
		mockList.add('fred');
		mockList.add('fred');

		// Then
		((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.atMost(5))).add(ADGLIB_Match.anyString());
	}

	@isTest
	private static void thatVerifiesAtMostSameNumberOfTimesWithMatchers()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('bob');
		mockList.add('fred');
		mockList.add('fred');

		// Then
		((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.atMost(3))).add(ADGLIB_Match.anyString());
	}

	@isTest
	private static void thatThrownExceptionIfCalledMoreThanAtMostNumberOfTimesWithMatchers()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('bob');
		mockList.add('fred');
		mockList.add('fred');
		mockList.add('fred');

		// Then
		try
		{
			((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.atMost(3))).add(ADGLIB_Match.anyString());

			System.assert(false, 'an exception was expected because we are asserting that the method is called 3 times when instead is called four times');
		}
		catch(ADGLIB_ApexMocks.ApexMocksException ex)
		{
			String expectedMessage = 'Expected : 3 or fewer times, Actual: 4 -- Wanted but not invoked: ' + ADGLIB_MyList.getStubClassName() + '.add(String).';
			String actualMessage = ex.getMessage();
			System.assertEquals(expectedMessage, actualMessage,
				'the exception has been caught as expected, however the message is not as expected');
		}
	}

	/*
	 *	atLeastOnce
	 */

	@isTest
	private static void thatVerifiesAtLeastOnceNumberOfTimes()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('bob');
		mockList.add('fred');
		mockList.add('fred');

		// Then
		((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.atLeastOnce())).add('bob');
	}

	@isTest
	private static void thatVerifiesAtLeastOnceNumberOfTimesWhenIsCalledMoreTimes()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('bob');
		mockList.add('fred');
		mockList.add('bob');
		mockList.add('fred');

		// Then
		((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.atLeastOnce())).add('bob');
	}

	@isTest
	private static void thatThrownExceptionIfCalledLessThanAtLeastOnceNumberOfTimes()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('rob');
		mockList.add('fred');

		// Then
		try
		{
			((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.atLeastOnce())).add('bob');

			System.assert(false, 'an exception was expected because we are asserting that the method is called at least once when instead is never called');
		}
		catch(ADGLIB_ApexMocks.ApexMocksException ex)
		{
			String expectedMessage = 'Expected : 1 or more times, Actual: 0 -- Wanted but not invoked: ' + ADGLIB_MyList.getStubClassName() + '.add(String).';
			String actualMessage = ex.getMessage();
			System.assertEquals(expectedMessage, actualMessage,
				'the exception has been caught as expected, however the message is not as expected');
		}
	}

	@isTest
	private static void thatVerifiesAtLeastOnceNumberOfTimesWithMatchers()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('bob');
		mockList.add('fred', 'fred', 'fred', 'fred');

		// Then
		((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.atLeastOnce())).add(ADGLIB_Match.anyString());
	}

	@isTest
	private static void thatVerifiesAtLeastOnceNumberOfTimesWhenIsCalledMoreTimesWithMatchers()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('bob');
		mockList.add('fred', 'fred', 'fred', 'fred');
		mockList.add('bob');
		mockList.add('fred', 'fred', 'fred', 'fred');
		mockList.add('bob');
		mockList.add('fred', 'fred', 'fred', 'fred');

		// Then
		((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.atLeastOnce())).add(ADGLIB_Match.anyString());
	}

	@isTest
	private static void thatThrownExceptionIfCalledLessThanAtLeastOnceNumberOfTimesWithMatchers()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('fred', 'fred', 'fred', 'fred');
		mockList.add('fred', 'fred', 'fred', 'fred');
		mockList.add('fred', 'fred', 'fred', 'fred');

		// Then
		try
		{
			((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.atLeastOnce())).add(ADGLIB_Match.anyString());

			System.assert(false, 'an exception was expected because we are asserting that the method is called at lest once when instead is never called');
		}
		catch(ADGLIB_ApexMocks.ApexMocksException ex)
		{
			String expectedMessage = 'Expected : 1 or more times, Actual: 0 -- Wanted but not invoked: ' + ADGLIB_MyList.getStubClassName() + '.add(String).';
			String actualMessage = ex.getMessage();
			System.assertEquals(expectedMessage, actualMessage,
				'the exception has been caught as expected, however the message is not as expected');
		}
	}

	/*
	 *	between
	 */

	@isTest
	private static void thatVerifiesBetweenNumberOfTimes()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('bob');
		mockList.add('fred');
		mockList.add('bob');
		mockList.add('fred');
		mockList.add('bob');
		mockList.add('fred');
		mockList.add('bob');
		mockList.add('fred');

		// Then
		((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.between(3, 5))).add('bob');
	}

	@isTest
	private static void thatBetweenThrownExceptionIfCalledLessThanAtLeastNumberOfTimes()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('bob');
		mockList.add('fred');
		mockList.add('bob');

		// Then
		try
		{
			((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.between(3, 5))).add('bob');

			System.assert(false, 'an exception was expected because we are asserting that the method is called at least 3 times when instead is called only twice');
		}
		catch(ADGLIB_ApexMocks.ApexMocksException ex)
		{
			String expectedMessage = 'Expected : 3 or more times, Actual: 2 -- Wanted but not invoked: ' + ADGLIB_MyList.getStubClassName() + '.add(String).';
			String actualMessage = ex.getMessage();
			System.assertEquals(expectedMessage, actualMessage,
				'the exception has been caught as expected, however the message is not as expected');
		}
	}

	@isTest
	private static void thatVerifiesBetweenNumberOfTimesWithMatchers()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('bob');
		mockList.add('fred');
		mockList.add('fred');
		mockList.add('bob');

		// Then
		((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.between(3, 5))).add(ADGLIB_Match.anyString());
	}

	@isTest
	private static void thatBetweenThrownExceptionIfCalledLessThanAtLeastNumberOfTimesWithMatchers()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('bob');
		mockList.add('fred');

		// Then
		try
		{
			((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.between(3, 5))).add(ADGLIB_Match.anyString());

			System.assert(false, 'an exception was expected because we are asserting that the method is called 3 times when instead is called only twice');
		}
		catch(ADGLIB_ApexMocks.ApexMocksException ex)
		{
			String expectedMessage = 'Expected : 3 or more times, Actual: 2 -- Wanted but not invoked: ' + ADGLIB_MyList.getStubClassName() + '.add(String).';
			String actualMessage = ex.getMessage();
			System.assertEquals(expectedMessage, actualMessage,
				'the exception has been caught as expected, however the message is not as expected');
		}
	}

	@isTest
	private static void thatBetweenThrownExceptionIfCalledMoreThanAtMostNumberOfTimes()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('bob');
		mockList.add('fred');
		mockList.add('fred');
		mockList.add('bob');
		mockList.add('bob');
		mockList.add('bob');
		mockList.add('bob');
		mockList.add('bob');
		mockList.add('fred');

		// Then
		try
		{
			((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.between(3, 5))).add('bob');

			System.assert(false, 'an exception was expected because we are asserting that the method is called at most 5 times when instead is called six times');
		}
		catch(ADGLIB_ApexMocks.ApexMocksException ex)
		{
			String expectedMessage = 'Expected : 5 or fewer times, Actual: 6 -- Wanted but not invoked: ' + ADGLIB_MyList.getStubClassName() + '.add(String).';
			String actualMessage = ex.getMessage();
			System.assertEquals(expectedMessage, actualMessage,
				'the exception has been caught as expected, however the message is not as expected');
		}
	}

	@isTest
	private static void thatBetweenThrownExceptionIfCalledMoreThanAtMostNumberOfTimesWithMatchers()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('bob');
		mockList.add('fred');
		mockList.add('bob');
		mockList.add('fred');
		mockList.add('fred');
		mockList.add('fred');

		// Then
		try
		{
			((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.between(3, 5))).add(ADGLIB_Match.anyString());

			System.assert(false, 'an exception was expected because we are asserting that the method is called 5 times when instead is called six times');
		}
		catch(ADGLIB_ApexMocks.ApexMocksException ex)
		{

			String expectedMessage = 'Expected : 5 or fewer times, Actual: 6 -- Wanted but not invoked: ' + ADGLIB_MyList.getStubClassName() + '.add(String).';
			String actualMessage = ex.getMessage();
			System.assertEquals(expectedMessage, actualMessage,
				'the exception has been caught as expected, however the message is not as expected');
		}
	}

	/*
	 *	never
	 */

	@isTest
	private static void verifyNeverMethodHasNotBeenCalled()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('bob1');
		mockList.add('bob2');
		mockList.add('bob3');

		// Then
		((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.never())).add('bob');
	}

	@isTest
	private static void verifyNeverMethodHasBeenNotCalledWithMatchers()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('fred', 'fred', 'fred', 'fred');
		mockList.add('fred', 'fred', 'fred', 'fred');
		mockList.add('fred', 'fred', 'fred', 'fred');

		// Then
		((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.never())).add(ADGLIB_Match.anyString());
	}

	@isTest
	private static void thatVerifyNeverFailsWhenCalledMoreTimes()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('bob');
		mockList.add('bob');

		// Then
		try
		{
			((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.never())).add('bob');

			System.assert(false, 'an exception was expected');
		}
		catch(Exception exc)
		{
			assertFailMessage(exc.getMessage(), 0, 2);
		}
	}

	@isTest
	private static void thatVerifyNeverFailsWhenCalledMoreTimesWithMatchers()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('bob');
		mockList.add('bob');
		mockList.add('bob');

		// Then
		try
		{
			((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.never())).add(ADGLIB_Match.anyString());

			System.assert(false, 'an exception was expected');
		}
		catch(Exception exc)
		{
			assertFailMessage(exc.getMessage(), 0, 3);
		}
	}



	/*
	 *	atLeastOnce
	 */

	@isTest
	private static void thatVerifiesAtLeastOnce()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('bob');
		mockList.add('fred');
		mockList.add('bob');
		mockList.add('bob');

		// Then
		((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.atLeastOnce())).add('bob');
	}

	@isTest
	private static void thatVerifiesAtLeastOnceWhenIsCalledMoreTimes()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('bob');
		mockList.add('fred');
		mockList.add('bob');
		mockList.add('fred');
		mockList.add('bob');
		mockList.add('fred');

		// Then
		((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.atLeastOnce())).add('bob');
	}

	@isTest
	private static void thatThrownExceptionIfCalledLessThanAtLeastOnce()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('bob');
		mockList.add('fred');
		mockList.add('bob');

		// Then
		try
		{
			((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.atLeastOnce())).add('rob');

			System.assert(false, 'an exception was expected because we are asserting that the method is called one times when instead is not called');
		}
		catch(ADGLIB_ApexMocks.ApexMocksException ex)
		{
			String expectedMessage = 'Expected : 1 or more times, Actual: 0 -- Wanted but not invoked: ' + ADGLIB_MyList.getStubClassName() + '.add(String).';
			String actualMessage = ex.getMessage();
			System.assertEquals(expectedMessage, actualMessage,
				'the exception has been caught as expected, however the message is not as expected');
		}
	}

	@isTest
	private static void thatVerifiesAtLeastOnceWithMatchers()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('bob');
		mockList.add('fred');

		// Then
		((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.atLeastOnce())).add(ADGLIB_Match.anyString());
	}

	@isTest
	private static void thatVerifiesAtLeastOnceWhenIsCalledMoreTimesWithMatchers()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('bob');
		mockList.add('fred');
		mockList.add('fred');
		mockList.add('fred');

		// Then
		((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.atLeastOnce())).add(ADGLIB_Match.anyString());
	}

	@isTest
	private static void thatThrownExceptionIfCalledLessThanAtLeastOnceWithMatchers()
	{
		// Given
		ADGLIB_ApexMocks mocks = new ADGLIB_ApexMocks();
		ADGLIB_MyList mockList = (ADGLIB_MyList)mocks.mock(ADGLIB_MyList.class);

		// When
		mockList.add('bob');
		mockList.add('fred');

		// Then
		try
		{
			((ADGLIB_MyList.IList) mocks.verify(mockList, mocks.atLeastOnce())).add(ADGLIB_Match.stringStartsWith('rob'));

			System.assert(false, 'an exception was expected because we are asserting that the method is called once when instead is not called');
		}
		catch(ADGLIB_ApexMocks.ApexMocksException ex)
		{
			String expectedMessage = 'Expected : 1 or more times, Actual: 0 -- Wanted but not invoked: ' + ADGLIB_MyList.getStubClassName() + '.add(String).';
			String actualMessage = ex.getMessage();
			System.assertEquals(expectedMessage, actualMessage,
				'the exception has been caught as expected, however the message is not as expected');
		}
	}

	/*
	 *	HELPER METHODS
	 */

	private static void assertFailMessage(String exceptionMessage, Integer expectedInvocations, Integer actualsInvocations)
	{
		String expectedMessage =
			String.format(BASIC_VERIFY_ASSERTION_MESSAGE,
				new List<String>{String.valueOf(expectedInvocations), String.valueOf(actualsInvocations)});
		System.assert(exceptionMessage.contains(expectedMessage),
			'The exception was caught, but the message was not as expected. ' +
			'Expected: [' + expectedMessage + '],  Actual: [' + exceptionMessage + '].');
	}

	/*
	 *	HELPER CLASSES
	 */

	private class isOdd implements ADGLIB_IMatcher
	{
		public Boolean matches(Object arg)
		{
			return arg instanceof Integer ? Math.mod((Integer)arg, 2) == 1: false;
		}
	}

	private class isEven implements ADGLIB_IMatcher
	{
		public Boolean matches(Object arg)
		{
			return arg instanceof Integer ? Math.mod((Integer)arg, 2) == 0: false;
		}
	}
}
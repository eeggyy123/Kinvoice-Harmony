import localUnitTest from './LocalUnit.test';
import httpTestSuite from './http.test';

export default function testsuite() {
  localUnitTest();
  httpTestSuite();
}
import React from 'react';
import { ErrorPage } from './ErrorPage';

export const UnauthorizedPage: React.FC = () => {
  return <ErrorPage code="401" backUrl="/login" />;
};

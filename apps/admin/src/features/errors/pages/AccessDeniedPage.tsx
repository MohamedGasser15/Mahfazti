import React from 'react';
import { ErrorPage } from './ErrorPage';

export const AccessDeniedPage: React.FC = () => {
  return <ErrorPage code="403" />;
};

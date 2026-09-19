import { ErrorPage, type ErrorPageProps } from './ErrorPage';

export const ServerErrorPage: React.FC<Partial<ErrorPageProps>> = (props) => {
  return <ErrorPage code="500" showRetry={true} {...props} />;
};

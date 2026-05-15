'use client';

import { useEffect, useRef, useState } from 'react';
import Dialog from './Dialog';
import { linkGoogleAccountAction } from '@/app/actions/auth';
import { Loader2 } from 'lucide-react';

type GoogleCredentialResponse = {
  credential: string;
};

type GoogleIdConfiguration = {
  client_id: string;
  callback: (response: GoogleCredentialResponse) => void;
};

type GoogleButtonConfiguration = {
  theme?: 'outline' | 'filled_blue' | 'filled_black';
  size?: 'large' | 'medium' | 'small';
  text?: 'signin_with' | 'signup_with' | 'continue_with' | 'signin';
  shape?: 'rectangular' | 'pill' | 'circle' | 'square';
  width?: number;
};

type GoogleNamespace = {
  accounts: {
    id: {
      initialize: (config: GoogleIdConfiguration) => void;
      renderButton: (parent: HTMLElement, options: GoogleButtonConfiguration) => void;
    };
  };
};

declare global {
  interface Window {
    google?: GoogleNamespace;
  }
}

let googleScriptLoader: Promise<void> | null = null;

function ensureGoogleScriptLoaded(): Promise<void> {
  if (typeof window === 'undefined') {
    return Promise.resolve();
  }

  if (window.google?.accounts?.id) {
    return Promise.resolve();
  }

  if (googleScriptLoader) {
    return googleScriptLoader;
  }

  googleScriptLoader = new Promise<void>((resolve, reject) => {
    const existing = document.querySelector<HTMLScriptElement>(
      'script[data-google-identity-script="true"]',
    );

    if (existing) {
      existing.addEventListener('load', () => resolve(), { once: true });
      existing.addEventListener('error', () => reject(new Error('Failed to load Google SDK')), {
        once: true,
      });
      return;
    }

    const script = document.createElement('script');
    script.src = 'https://accounts.google.com/gsi/client';
    script.async = true;
    script.defer = true;
    script.dataset.googleIdentityScript = 'true';
    script.onload = () => resolve();
    script.onerror = () => reject(new Error('Failed to load Google SDK'));
    document.head.appendChild(script);
  });

  return googleScriptLoader;
}

interface GoogleLinkDialogProps {
  isOpen: boolean;
  onClose: () => void;
  isLinked?: boolean;
  onLinked?: () => void;
}

export default function GoogleLinkDialog({
  isOpen,
  onClose,
  isLinked = false,
  onLinked,
}: GoogleLinkDialogProps) {
  const googleClientId = process.env.NEXT_PUBLIC_GOOGLE_CLIENT_ID?.trim();
  const configError = googleClientId
    ? null
    : 'Google link is not configured. Please set NEXT_PUBLIC_GOOGLE_CLIENT_ID.';
  const buttonRef = useRef<HTMLDivElement>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [message, setMessage] = useState<string | null>(null);

  useEffect(() => {
    if (!isOpen || isLinked || !googleClientId) {
      return;
    }

    let disposed = false;

    const initGoogleButton = async () => {
      try {
        await ensureGoogleScriptLoaded();
        if (disposed || !buttonRef.current || !window.google?.accounts?.id) {
          return;
        }

        buttonRef.current.innerHTML = '';

        window.google.accounts.id.initialize({
          client_id: googleClientId,
          callback: async (response: GoogleCredentialResponse) => {
            if (!response.credential) {
              setError('Google did not return an ID token.');
              return;
            }

            setIsSubmitting(true);
            setError(null);
            const result = await linkGoogleAccountAction(response.credential);
            setIsSubmitting(false);

            if (result.success) {
              setMessage(result.message || 'Google account linked successfully.');
              onLinked?.();
              return;
            }

            setError(result.error || 'Failed to link Google account.');
          },
        });

        window.google.accounts.id.renderButton(buttonRef.current, {
          theme: 'outline',
          size: 'large',
          text: 'continue_with',
          shape: 'pill',
          width: 280,
        });
      } catch {
        if (!disposed) {
          setError('Unable to initialize Google Sign-In. Please try again.');
        }
      }
    };

    void initGoogleButton();

    return () => {
      disposed = true;
    };
  }, [googleClientId, isLinked, isOpen, onLinked]);

  return (
    <Dialog isOpen={isOpen} onClose={onClose} title="Link Google Account">
      <div className="space-y-4">
        {isLinked ? (
          <div className="p-3 rounded-lg border border-emerald-200 bg-emerald-50 text-emerald-700 text-sm">
            Your account is already linked with Google.
          </div>
        ) : (
          <>
            <p className="text-sm text-slate-600">
              Connect your Google account to this profile. Google email must match your current
              account email.
            </p>
            <div className="min-h-[44px] flex items-center justify-center">
              {isSubmitting ? (
                <span className="inline-flex items-center gap-2 text-sm text-slate-600">
                  <Loader2 className="h-4 w-4 animate-spin" />
                  Linking Google account...
                </span>
              ) : (
                <div ref={buttonRef} />
              )}
            </div>
          </>
        )}

        {message && (
          <div className="p-3 rounded-lg border border-emerald-200 bg-emerald-50 text-emerald-700 text-sm">
            {message}
          </div>
        )}

        {(configError || error) && (
          <div className="p-3 rounded-lg border border-red-200 bg-red-50 text-red-600 text-sm">
            {configError || error}
          </div>
        )}
      </div>
    </Dialog>
  );
}

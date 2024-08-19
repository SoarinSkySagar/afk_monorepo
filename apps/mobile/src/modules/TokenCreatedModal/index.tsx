import {NDKEvent} from '@nostr-dev-kit/ndk';
import {useAccount} from '@starknet-react/core';
import {forwardRef, useEffect, useState} from 'react';

import {Modalize, Text} from '../../components';
import {TokenSymbol} from '../../constants/tokens';
import {useStyles, useWaitConnection} from '../../hooks';
import {useProfile} from "afk_nostr_sdk"
import {useDataKeys} from '../../hooks/keys/useDataKeys';
import {useInstantiateKeys} from '../../hooks/keys/useInstantiateKeys';
import {useTransactionModal} from '../../hooks/modals';
import {useDialog} from '../../hooks/modals/useDialog';
import {useTransaction} from '../../hooks/modals/useTransaction';
import {useWalletModal} from '../../hooks/modals/useWalletModal';
import {KeysUser} from '../../types/keys';
import {TipSuccessModalProps} from '../TipSuccessModal';
import {FormInstantiateKey} from './FormInstantiateKey';
import stylesheet from './styles';
import { FormLaunchToken } from '../LaunchTokenPump/FormLaunchToken';

export type KeyModal = Modalize;

export enum KeyModalAction {
  INSTANTIATE,
  BUY,
  SELL,
}
export type TokenCreateModalProps = {
  event?: NDKEvent;
  starknetAddress?: string;
  action?: KeyModalAction;

  show?: (event?: NDKEvent, starknetAddress?: string, action?: KeyModalAction) => void;
  hide?: () => void;
  showSuccess?: (props: TipSuccessModalProps) => void;
  hideSuccess?: () => void;
};

export const TokenCreateModal = forwardRef<Modalize, TokenCreateModalProps>(
  ({event, hide: hideKeyModal, showSuccess, hideSuccess, starknetAddress, action}, ref) => {
    const styles = useStyles(stylesheet);
    const [token, setToken] = useState<TokenSymbol>(TokenSymbol.ETH);
    const [amount, setAmount] = useState<string>('');
    const {data: profile} = useProfile({publicKey: event?.pubkey});
    const [myKey, setMyKey] = useState<KeysUser | undefined>();
    const account = useAccount();
    const walletModal = useWalletModal();
    const {showDialog, hideDialog} = useDialog();
    const isActive = !!amount && !!token;


    return (
      <Modalize
        title="Token launch"
        ref={ref}
        disableScrollIfPossible={false}
        modalStyle={styles.modal}
      >
        <FormLaunchToken
          //  show={showDialog}
          showSuccess={showSuccess}
          hide={hideDialog}
          hideSuccess={hideSuccess}
          event={event}
          starknetAddress={starknetAddress}
        ></FormLaunchToken>
        {/* 
        {!action || (action == KeyModalAction?.INSTANTIATE)
          // || account?.address == starknetAddress &&
          &&
          <FormInstantiateKey
            //  show={showDialog} 
            showSuccess={showSuccess}
            hide={hideDialog}
            hideSuccess={hideSuccess}

            event={event}
            action={action}
            starknetAddress={starknetAddress}

          ></FormInstantiateKey>
        } */}

        <Text
          weight="semiBold"
          color="inputPlaceholder"
          fontSize={13}
          align="center"
          style={styles.comment}
        >
         Launch & pump the coins!
        </Text>
      </Modalize>
    );
  },
);
TokenCreateModal.displayName = 'TokenCreateModal';
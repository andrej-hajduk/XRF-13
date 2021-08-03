import { useBackend, useLocalState } from '../backend';
import { Button, Section, Box, LabeledList, ProgressBar, Modal, Divider, Tabs, Stack } from '../components';
import { decodeHtmlEntities } from 'common/string';
import { Window } from '../layouts';


type VendingData = {
  vendor_name: string,
  displayed_records: VendingRecord[],
  tabs: string[],
  stock: VendingStock,
  price: VendingPrice,
  currently_vending: VendingRecord | null,
  credits: number,
};

type VendingStock = {
  [ key: string ]: number
};

type VendingPrice = {
  [ key: string ]: number
};

type VendingRecord = {
  product_name: string,
  product_color: string,
  prod_price: number,
  prod_desc: string,
  ref: string,
  tab: string,
}

export const Uplink = (props, context) => {
  const { data } = useBackend<VendingData>(context);

  const {
    vendor_name,
    currently_vending,
    tabs,
    credits,
  } = data;

  const [
    showDesc,
    setShowDesc,
  ] = useLocalState(context, 'showDesc', null);

  const [
    showEmpty,
    setShowEmpty,
  ] = useLocalState(context, 'showEmpty', false);

  const [
    selectedTab,
    setSelectedTab,
  ] = useLocalState(context, 'selectedTab', tabs.length ? tabs[0] : null);

  return (
    <Window
      title={vendor_name || "Vending Machine"}
      width={500}
      height={600}>
      {showDesc && (
        <Modal width="400px">
          <Box>{showDesc}</Box>
          <Button
            content="Dismiss"
            onClick={() => setShowDesc(null)} />
        </Modal>
      )}
      <Window.Content scrollable>
        <Section
          title={"Select an item - "+credits+" Dollars"}
          buttons={
            <Button
              icon="power-off"
              selected={showEmpty}
              onClick={() => setShowEmpty(!showEmpty)}>
              Show sold-out items
            </Button>
          }>
          {(tabs.length > 0 && (
            <Section
              lineHeight={1.75}
              textAlign="center">
              <Tabs>
                <Stack
                  wrap="wrap">
                  {tabs.map(tabname => {
                    return (
                      <Stack.Item
                        m={0.5}
                        grow={tabname.length}
                        key={tabname}>
                        <Tabs.Tab
                          selected={tabname === selectedTab}
                          onClick={() => setSelectedTab(tabname)}>
                          {tabname}
                        </Tabs.Tab>
                      </Stack.Item>
                    );
                  })}
                </Stack>
              </Tabs>
              <Divider />
            </Section>
          ))}
          <Products />
        </Section>
      </Window.Content>
    </Window>
  );
};


type VendingProductEntryProps = {
  stock: number,
  price: number,
  product_color: string,
  product_name: string,
  prod_desc: string,
  prod_ref: string,
}

const ProductEntry = (props: VendingProductEntryProps, context) => {
  const { act, data } = useBackend<VendingData>(context);

  const {
    currently_vending,
  } = data;

  const {
    stock,
    price,
    product_color,
    product_name,
    prod_desc,
    prod_ref,
  } = props;

  const [
    showDesc,
    setShowDesc,
  ] = useLocalState(context, 'showDesc', null);

  return (
    <LabeledList.Item
      labelColor="white"
      buttons={
        <>
          {stock >= 0 && (
            <Box inline>
              <ProgressBar
                value={stock}
                maxValue={stock}
                ranges={{
                  good: [10, Infinity],
                  average: [5, 10],
                  bad: [0, 5],
                }}>{stock} left
              </ProgressBar>
            </Box>)}
          <Box
            inline
            width="4px" />
          <Button
            onClick={() => act(
              'vend',
              { vend: prod_ref })}
            disabled={!stock}>
			{price ? ('Buy (' + price + '$)') : ('Vend')}
          </Button>
        </>
      }
      label={product_name}>
      {!!prod_desc && (
        <Button
          onClick={() => setShowDesc(prod_desc)}>?
        </Button>)}
    </LabeledList.Item>
  );
};


const Products = (props, context) => {
  const { data } = useBackend<VendingData>(context);

  const {
    displayed_records,
    stock,
    price,
    tabs,
  } = data;

  const [
    selectedTab,
    setSelectedTab,
  ] = useLocalState(context, 'selectedTab', tabs.length ? tabs[0] : null);

  const [
    showEmpty,
    setShowEmpty,
  ] = useLocalState(context, 'showEmpty', false);

  return (
    <Section>
      <LabeledList>
        {displayed_records.length === 0 ? (
          <Box color="red">No product loaded!</Box>
        ) : (
          displayed_records
            .filter(record => !record.tab || record.tab === selectedTab)
            .map(display_record => {
              return (
                ((showEmpty || !!stock[display_record.product_name]) && (
                  <ProductEntry
                    stock={stock[display_record.product_name]}
                    price={price[display_record.product_name]}
                    key={display_record.product_name}
                    product_color={display_record.product_color}
                    product_name={display_record.product_name}
                    prod_desc={display_record.prod_desc}
                    prod_ref={display_record.ref} />
                ))
              );
            })
        )}
      </LabeledList>
    </Section>
  );
};
